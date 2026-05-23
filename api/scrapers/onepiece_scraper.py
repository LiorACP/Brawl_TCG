# One Piece TCG
# La página de reglas es un índice de PDFs con descripciones de una sola línea.
# Buscamos el PDF de reglas exhaustivas (Comprehensive Rules) y lo parseamos con pdfplumber.
# Si no lo encontramos, recurrimos a la página de FAQ que sí tiene contenido HTML.

import io
import httpx
import pdfplumber
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

RULES_URL = "https://en.onepiece-cardgame.com/rules/"
FAQ_URL = "https://en.onepiece-cardgame.com/faq/"

BROWSER_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}

# Palabras clave para identificar el PDF de reglas exhaustivas
COMP_KEYWORDS = ("comprehensive", "comp_rules", "comp-rules", "full-rules", "full_rules")


class OnePieceScraper(BaseScraper):
    game_id = GameId.onepiece
    version = "2024"

    async def fetch(self) -> list[Rule]:
        async with httpx.AsyncClient(timeout=60, follow_redirects=True,
                                     headers=BROWSER_HEADERS) as client:
            pdf_url = await self._find_comp_rules_pdf(client)
            if pdf_url:
                resp = await client.get(pdf_url)
                if resp.status_code == 200:
                    rules = self._parse_pdf(resp.content)
                    if rules:
                        return rules

            # Fallback: parsear la FAQ en HTML
            return await self._parse_faq(client)

    async def _find_comp_rules_pdf(self, client: httpx.AsyncClient) -> str | None:
        try:
            resp = await client.get(RULES_URL)
            if resp.status_code != 200:
                return None
            soup = BeautifulSoup(resp.text, "lxml")
            candidates: list[tuple[int, str]] = []
            for a in soup.find_all("a", href=True):
                href: str = a["href"]
                if ".pdf" not in href.lower():
                    continue
                href_lower = href.lower()
                link_text = a.get_text(strip=True).lower()
                score = sum(1 for k in COMP_KEYWORDS if k in href_lower or k in link_text)
                # También puntuar si el texto del enlace menciona "comprehensive rules"
                if "comprehensive" in link_text:
                    score += 2
                if score > 0:
                    full = href if href.startswith("http") else "https://en.onepiece-cardgame.com" + href
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

    async def _parse_faq(self, client: httpx.AsyncClient) -> list[Rule]:
        """Fallback: extrae preguntas y respuestas de la página de FAQ HTML."""
        rules: list[Rule] = []
        now = datetime.utcnow()
        idx = 0
        try:
            resp = await client.get(FAQ_URL)
            if resp.status_code != 200:
                return rules
            soup = BeautifulSoup(resp.text, "lxml")

            # Buscamos pares pregunta/respuesta en elementos details, dl o divs con clases faq
            for item in soup.find_all(["details", "div", "li"],
                                      class_=lambda c: c and any(
                                          k in " ".join(c).lower() for k in ("faq", "question", "qa", "accordion")
                                      )):
                question = item.find(["summary", "dt", "h3", "h4", "strong"])
                answer = item.find(["p", "dd", "div"])
                if not question or not answer:
                    continue
                title = question.get_text(strip=True)
                body = answer.get_text(" ", strip=True)
                if not title or len(body) < 15:
                    continue
                idx += 1
                rules.append(Rule(
                    id=f"onepiece-faq-{idx:03d}",
                    game=GameId.onepiece,
                    title=title,
                    category="FAQ",
                    body=body,
                    language="en",
                    version=self.version,
                    search_keywords=self._keywords(title, body),
                    examples=[],
                    last_updated=now,
                ))
        except Exception:
            pass
        return rules

    def _make_rule(self, idx: int, title: str, body: str, now: datetime) -> Rule:
        return Rule(
            id=f"onepiece-sec-{idx:03d}",
            game=GameId.onepiece,
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
        # Sección numerada: "1.", "1.0", "2.3"
        if len(words) >= 2 and words[0].rstrip(".").replace(".", "").isdigit():
            return True
        # Mayúsculas cortas: "TURN STRUCTURE", "CARD TYPES"
        if line.isupper() and 1 <= len(words) <= 8:
            return True
        # Title case corta
        if line.istitle() and 1 <= len(words) <= 6 and len(line) < 50:
            return True
        return False

    def _infer_category(self, title: str) -> str:
        t = title.lower()
        if any(k in t for k in ("attack", "battle", "blocker", "block")):
            return "Battle"
        if any(k in t for k in ("leader", "don!!", "don", "cost")):
            return "Leader & DON!!"
        if any(k in t for k in ("character", "event", "stage")):
            return "Card Types"
        if any(k in t for k in ("turn", "phase", "step")):
            return "Turn Structure"
        if any(k in t for k in ("trigger", "effect", "counter")):
            return "Triggers & Effects"
        if any(k in t for k in ("life", "ko", "knock", "lose", "win")):
            return "Life & KO"
        if any(k in t for k in ("setup", "start", "deck", "objective")):
            return "Setup"
        return "General"
