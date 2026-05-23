# Flesh and Blood
# El sitio oficial de reglas movió a rules.fabtcg.com, que ofrece un TXT descargable
# con formato numerado igual que Magic (1.0 Section, 1.0.1 Regla, Example: ...).
# Buscamos el enlace al TXT en la página principal y lo parseamos.
# NOTA: El servidor responde con Brotli si se pide; excluimos "br" del Accept-Encoding
#       porque httpx no tiene soporte Brotli instalado en este entorno.

import re
import httpx
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

RULES_HOME = "https://rules.fabtcg.com/en/"
FALLBACK_TXT = "https://rules.fabtcg.com/txt/latest/en-fab-cr.txt"

# Sin "br" para que el servidor responda con gzip (httpx lo descomprime solo)
BROWSER_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.5",
}

# Cabeceras de capítulo/sección: "1 Game Concepts", "1.0 General", "1.1 Players"
_SECTION_RE = re.compile(r'^(\d+(?:\.\d+)?)\s{1,4}([A-Z].{2,80})$')
# Línea de regla individual: "1.0.1", "1.0.1a", "1.0.1b", etc.
_RULE_LINE_RE = re.compile(r'^\d+\.\d+\.\d+[a-z]?\s')

CATEGORY_MAP = {
    "1": "Game Concepts",
    "2": "Object Properties",
    "3": "Zones",
    "4": "Game Structure",
    "5": "Layers, Cards & Abilities",
    "6": "Effects",
    "7": "Combat",
    "8": "Keywords",
    "9": "Additional Rules",
}


class FabScraper(BaseScraper):
    game_id = GameId.fab
    version = "2.13"

    async def fetch(self) -> list[Rule]:
        async with httpx.AsyncClient(timeout=60, follow_redirects=True,
                                     headers=BROWSER_HEADERS) as client:
            txt_url = await self._find_txt_url(client)
            resp = await client.get(txt_url)
            resp.raise_for_status()
        self._extract_version(resp.text)
        return self._parse(resp.text)

    async def _find_txt_url(self, client: httpx.AsyncClient) -> str:
        try:
            resp = await client.get(RULES_HOME)
            if resp.status_code == 200:
                soup = BeautifulSoup(resp.text, "lxml")
                for a in soup.find_all("a", href=True):
                    href = a["href"]
                    if "en-fab-cr.txt" in href:
                        return href if href.startswith("http") else "https://rules.fabtcg.com" + href
        except Exception:
            pass
        return FALLBACK_TXT

    def _extract_version(self, text: str) -> None:
        # El TXT comienza con la versión en el bloque de preface
        m = re.search(r'\b(\d+\.\d+(?:\.\d+)?)\b', text[:500])
        if m:
            self.version = m.group(1)

    def _parse(self, text: str) -> list[Rule]:
        rules: list[Rule] = []
        now = datetime.utcnow()
        idx = 0

        current_num: str | None = None
        current_title: str | None = None
        current_body: list[str] = []
        current_examples: list[str] = []
        in_example = False

        def _flush():
            nonlocal idx
            if not current_title or not current_body:
                return
            body = " ".join(current_body).strip()
            if len(body) < 20:
                return
            chapter = current_num.split(".")[0] if current_num else "0"
            idx += 1
            rules.append(Rule(
                id=f"fab-{current_num or idx:03}",
                game=GameId.fab,
                title=current_title,
                category=CATEGORY_MAP.get(chapter, "General"),
                body=body,
                language="en",
                version=self.version,
                search_keywords=self._keywords(current_title, body),
                examples=list(current_examples),
                last_updated=now,
            ))

        for line in text.split("\n"):
            line = line.rstrip()
            if not line:
                in_example = False
                continue

            m = _SECTION_RE.match(line)
            if m:
                _flush()
                current_num = m.group(1)
                current_title = m.group(2).strip()
                current_body = []
                current_examples = []
                in_example = False
                continue

            if current_title is None:
                continue

            if line.startswith("Example:"):
                in_example = True
                current_examples.append(line[len("Example:"):].strip())
            elif in_example and not _RULE_LINE_RE.match(line):
                # Continuación del ejemplo en la línea siguiente
                if current_examples:
                    current_examples[-1] += " " + line.strip()
            else:
                in_example = False
                if _RULE_LINE_RE.match(line):
                    # Quito el número de regla del principio y añado al cuerpo
                    body_text = re.sub(r'^\d+\.\d+\.\d+[a-z]?\s+', '', line)
                    current_body.append(body_text.strip())
                else:
                    current_body.append(line.strip())

        _flush()
        return rules
