# Magic: The Gathering
# La página oficial de WotC tiene el enlace al TXT del reglamento actualizado
# Primero busco el enlace en la página de reglas y luego descargo el TXT
# Página de reglas: https://magic.wizards.com/en/rules

import re
import httpx
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

RULES_PAGE = "https://magic.wizards.com/en/rules"

BROWSER_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}

# Cada regla de Magic empieza con un número de capítulo, los mapeo a nombre legible
CATEGORY_MAP = {
    "1": "Game Concepts",
    "2": "Parts of a Card",
    "3": "Card Types",
    "4": "Zones",
    "5": "Turn Structure",
    "6": "Spells, Abilities, and Effects",
    "7": "Additional Rules",
    "8": "Multiplayer Rules",
    "9": "Casual Variants",
}


class MagicScraper(BaseScraper):
    game_id = GameId.magic
    version = "unknown"

    async def fetch(self) -> list[Rule]:
        async with httpx.AsyncClient(timeout=60, follow_redirects=True,
                                     headers=BROWSER_HEADERS) as client:
            # Busco el enlace al TXT del reglamento en la página oficial
            page = await client.get(RULES_PAGE)
            page.raise_for_status()
            txt_url = self._find_rules_txt(page.text)

            if not txt_url:
                raise RuntimeError("No se encontró el enlace al TXT del reglamento en magic.wizards.com/en/rules")

            rules_resp = await client.get(txt_url)
            rules_resp.raise_for_status()
            raw_text = rules_resp.text

        # Saco la versión del nombre del archivo (ej: MagicCompRules 20240308.txt)
        version_match = re.search(r'(\d{8})', txt_url)
        if version_match:
            raw_date = version_match.group(1)
            self.version = f"{raw_date[:4]}-{raw_date[4:6]}-{raw_date[6:]}"
        else:
            self.version = "2024"

        return self._parse_rules(raw_text)

    def _find_rules_txt(self, html: str) -> str | None:
        soup = BeautifulSoup(html, "lxml")
        for a in soup.find_all("a", href=True):
            href = a["href"]
            # El enlace al reglamento suele ser un .txt con "MagicCompRules" en el nombre
            if "MagicCompRules" in href and href.endswith(".txt"):
                return href if href.startswith("http") else "https://magic.wizards.com" + href
        # Fallback: buscar cualquier enlace a media.wizards.com con .txt
        for a in soup.find_all("a", href=True):
            href = a["href"]
            if "media.wizards.com" in href and ".txt" in href:
                return href
        return None

    def _parse_rules(self, text: str) -> list[Rule]:
        rules: list[Rule] = []
        # Las reglas tienen formato "100.1 Texto de la regla" o "100.1a Texto..."
        pattern = re.compile(r'^(\d+\.\d+\w*)\s+(.+)$', re.MULTILINE)
        now = datetime.utcnow()

        for match in pattern.finditer(text):
            rule_num = match.group(1)
            body = match.group(2).strip()
            if not body:
                continue

            chapter = rule_num.split(".")[0]
            category = CATEGORY_MAP.get(chapter, f"Chapter {chapter}")

            # Si la regla tiene un ejemplo lo separo del cuerpo principal
            examples: list[str] = []
            if "Example:" in body:
                parts = body.split("Example:", 1)
                body = parts[0].strip()
                examples = [parts[1].strip()]

            rules.append(Rule(
                id=f"magic-{rule_num}",
                game=GameId.magic,
                title=f"Regla {rule_num}",
                category=category,
                body=body,
                language="en",
                version=self.version,
                search_keywords=self._keywords(body),
                examples=examples,
                last_updated=now,
            ))

        return rules
