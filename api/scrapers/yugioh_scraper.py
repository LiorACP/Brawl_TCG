# Yu-Gi-Oh!
# La página del reglamento usa JS-rendering, así que descargamos el PDF directamente.
# Buscamos el enlace al PDF en la página; si no lo encontramos usamos la URL de respaldo.

import io
import httpx
import pdfplumber
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

RULEBOOK_URL = "https://www.yugioh-card.com/en/rulebook/"
FALLBACK_PDF = "https://www.yugioh-card.com/en/rulebook/SD_RuleBook_EN_V10.pdf"

BROWSER_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}


class YugiohScraper(BaseScraper):
    game_id = GameId.yugioh
    version = "2024"

    async def fetch(self) -> list[Rule]:
        async with httpx.AsyncClient(timeout=60, follow_redirects=True,
                                     headers=BROWSER_HEADERS) as client:
            pdf_url = await self._find_pdf_url(client)
            resp = await client.get(pdf_url)
            resp.raise_for_status()
        return self._parse_pdf(resp.content)

    async def _find_pdf_url(self, client: httpx.AsyncClient) -> str:
        try:
            resp = await client.get(RULEBOOK_URL)
            if resp.status_code == 200:
                soup = BeautifulSoup(resp.text, "lxml")
                for a in soup.find_all("a", href=True):
                    href = a["href"]
                    if ".pdf" in href.lower() and any(
                        k in href.lower() for k in ("rule", "rulebook", "manual")
                    ):
                        return href if href.startswith("http") else "https://www.yugioh-card.com" + href
        except Exception:
            pass
        return FALLBACK_PDF

    @staticmethod
    def _fix_doubled_chars(text: str) -> str:
        """Corrige el artefacto de PDFs a doble columna donde cada carácter aparece duplicado."""
        words = text.split()
        fixed = []
        for w in words:
            # Si cada carácter del token aparece duplicado: "TTHHEE" → "THE"
            if len(w) >= 4 and len(w) % 2 == 0 and all(w[i] == w[i + 1] for i in range(0, len(w) - 1, 2)):
                fixed.append("".join(w[i] for i in range(0, len(w), 2)))
            else:
                fixed.append(w)
        return " ".join(fixed)

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
                    line = self._fix_doubled_chars(line.strip())
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

        # Último bloque
        if current_title and current_body:
            body = " ".join(current_body).strip()
            if len(body) >= 30:
                idx += 1
                rules.append(self._make_rule(idx, current_title, body, now))

        return rules

    def _make_rule(self, idx: int, title: str, body: str, now: datetime) -> Rule:
        return Rule(
            id=f"yugioh-sec-{idx:03d}",
            game=GameId.yugioh,
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
        # Línea corta en mayúsculas: "THE CARDS", "HOW TO WIN", "GAME PLAY"
        if line.isupper() and 1 <= len(words) <= 8:
            return True
        # Línea en title case y corta: "Card Types", "Turn Structure"
        if line.istitle() and 1 <= len(words) <= 6 and len(line) < 50:
            return True
        return False

    def _infer_category(self, title: str) -> str:
        t = title.lower()
        if any(k in t for k in ("turn", "phase", "standby", "draw", "main", "end")):
            return "Turn Structure"
        if any(k in t for k in ("monster", "spell", "trap", "normal", "effect",
                                  "ritual", "fusion", "synchro", "xyz", "link", "pendulum")):
            return "Card Types"
        if any(k in t for k in ("attack", "battle", "damage", "destroy")):
            return "Battle"
        if any(k in t for k in ("chain", "resolv", "activate")):
            return "Effects & Chains"
        if any(k in t for k in ("summon", "special", "tribute")):
            return "Summoning"
        if any(k in t for k in ("win", "lose", "life point", "duel", "field")):
            return "Game Rules"
        return "General"
