"""
Magic: The Gathering — MTGJSON Comprehensive Rules
Fuente: https://mtgjson.com/api/v5/MagicCompRules.json
El JSON contiene el texto completo de las reglas en campo 'data.rules'.
Cada regla tiene número (ej: "100.1") y texto.
"""
import re
import httpx
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

MTGJSON_URL = "https://mtgjson.com/api/v5/MagicCompRules.json"

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
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.get(MTGJSON_URL)
            resp.raise_for_status()
            payload = resp.json()

        meta = payload.get("meta", {})
        self.version = meta.get("version", "unknown")
        raw_text: str = payload.get("data", {}).get("rules", "")

        return self._parse_rules(raw_text)

    def _parse_rules(self, text: str) -> list[Rule]:
        rules: list[Rule] = []
        # Cada regla empieza con un número como "100.1" o "100.1a"
        pattern = re.compile(r'^(\d+\.\d+\w*)\s+(.+)$', re.MULTILINE)
        now = datetime.utcnow()

        for match in pattern.finditer(text):
            rule_num = match.group(1)
            body = match.group(2).strip()
            if not body:
                continue

            chapter = rule_num.split(".")[0]
            category = CATEGORY_MAP.get(chapter, f"Chapter {chapter}")

            # Detectar ejemplos: texto después de "Example:"
            examples: list[str] = []
            if "Example:" in body:
                parts = body.split("Example:", 1)
                body = parts[0].strip()
                examples = [parts[1].strip()]

            rule = Rule(
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
            )
            rules.append(rule)

        return rules
