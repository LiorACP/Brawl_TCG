# Disney Lorcana
# La página de recursos es una lista de PDFs sin contenido de reglas útil en HTML.
# Buscamos en esa página el PDF de reglas principales (Core Rules / Comprehensive Rules)
# y lo parseamos con pdfplumber.

import io
import httpx
import pdfplumber
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

RESOURCES_URL = "https://www.disneylorcana.com/en-US/resources"

BROWSER_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}

import re as _re

# Tokens de idioma no inglés que pueden aparecer en el nombre del archivo
_NON_EN_PATTERN = _re.compile(
    r'[-_](?:de|fr|it|es|pt|deutsch|fran[cç]ais|italiano|espa[nñ]ol)[-_.]',
    _re.IGNORECASE,
)

def _is_english_pdf(href: str) -> bool:
    filename = href.split("/")[-1]
    return not bool(_NON_EN_PATTERN.search(filename))


class LorcanaScraper(BaseScraper):
    game_id = GameId.lorcana
    version = "2024"

    async def fetch(self) -> list[Rule]:
        async with httpx.AsyncClient(timeout=60, follow_redirects=True,
                                     headers=BROWSER_HEADERS) as client:
            pdf_url = await self._find_rules_pdf(client)
            if not pdf_url:
                return []
            resp = await client.get(pdf_url)
            resp.raise_for_status()
        return self._parse_pdf(resp.content)

    async def _find_rules_pdf(self, client: httpx.AsyncClient) -> str | None:
        try:
            resp = await client.get(RESOURCES_URL)
            if resp.status_code != 200:
                return None
            soup = BeautifulSoup(resp.text, "lxml")
            candidates: list[tuple[int, str]] = []
            for a in soup.find_all("a", href=True):
                href: str = a["href"]
                if ".pdf" not in href.lower():
                    continue
                if not _is_english_pdf(href):
                    continue
                href_lower = href.lower()
                link_text = a.get_text(strip=True).lower()
                score = 0
                # Máxima prioridad: comprehensive rules en inglés
                if "comprehensive" in href_lower:
                    score += 10
                # CRUpdate = Comprehensive Rules Update
                if "crupdate" in href_lower or "_cr" in href_lower:
                    score += 8
                # Tournament rules en inglés también son útiles
                if "tournament" in href_lower and "rules" in href_lower:
                    score += 5
                # Starter deck rules — útiles pero menos completas
                if "starter" in href_lower or "starterDeck" in href_lower.replace("%20", ""):
                    score += 2
                # Ignorar notas de expansión y materiales de marketing
                if any(k in href_lower for k in ("setreleasenotes", "opkit", "marketing", "lore_guide", "lore%20guide")):
                    score -= 5
                if score > 0:
                    full = href if href.startswith("http") else "https://www.disneylorcana.com" + href
                    candidates.append((score, full))
            if candidates:
                candidates.sort(key=lambda x: x[0], reverse=True)
                return candidates[0][1]
        except Exception:
            pass
        return None

    def _parse_pdf(self, pdf_bytes: bytes) -> list[Rule]:
        rules: list[Rule] = []
        now = datetime.utcnow()
        idx = 0
        current_title: str | None = None
        current_body: list[str] = []

        with pdfplumber.open(io.BytesIO(pdf_bytes)) as pdf:
            for page in pdf.pages:
                text = page.extract_text()
                if not text:
                    continue
                for line in text.split("\n"):
                    line = line.strip()
                    if not line:
                        continue
                    if self._is_heading(line):
                        if current_title and current_body:
                            body = " ".join(current_body).strip()
                            if len(body) >= 30:
                                idx += 1
                                rules.append(self._make_rule(idx, current_title, body, now))
                        current_title = line
                        current_body = []
                    elif current_title:
                        current_body.append(line)

        if current_title and current_body:
            body = " ".join(current_body).strip()
            if len(body) >= 30:
                idx += 1
                rules.append(self._make_rule(idx, current_title, body, now))

        return rules

    def _make_rule(self, idx: int, title: str, body: str, now: datetime) -> Rule:
        return Rule(
            id=f"lorcana-sec-{idx:03d}",
            game=GameId.lorcana,
            title=title,
            category=self._infer_category(title),
            body=body,
            language="en",
            version=self.version,
            search_keywords=self._keywords(title, body),
            examples=[],
            last_updated=now,
        )

    def _is_heading(self, line: str) -> bool:
        words = line.split()
        if not words:
            return False
        # Sección numerada: "1.", "1.2", "2.3.1"
        if len(words) >= 2 and words[0].rstrip(".").replace(".", "").isdigit():
            return True
        # Línea corta en mayúsculas: "TURN STRUCTURE", "PLAYING CARDS"
        if line.isupper() and 1 <= len(words) <= 8:
            return True
        # Title case corta
        if line.istitle() and 1 <= len(words) <= 6 and len(line) < 50:
            return True
        return False

    def _infer_category(self, title: str) -> str:
        t = title.lower()
        if any(k in t for k in ("sing", "song")):
            return "Songs"
        if any(k in t for k in ("quest", "location")):
            return "Questing & Locations"
        if any(k in t for k in ("challenge", "banish")):
            return "Challenging"
        if any(k in t for k in ("ink", "inkable", "cost")):
            return "Ink & Costs"
        if any(k in t for k in ("shift", "play", "playing")):
            return "Playing Cards"
        if any(k in t for k in ("ability", "keyword", "effect")):
            return "Keywords & Abilities"
        if any(k in t for k in ("turn", "phase", "step")):
            return "Turn Structure"
        if any(k in t for k in ("setup", "start", "begin", "objective", "win")):
            return "Setup & Objective"
        return "General"
