"""
Pokémon TCG — Scraping del reglamento oficial
Fuente: https://www.pokemon.com/us/pokemon-tcg/rules/
La página tiene secciones con anclas para cada bloque de reglas.
"""
import httpx
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

RULES_URL = "https://www.pokemon.com/us/pokemon-tcg/rules/"


class PokemonScraper(BaseScraper):
    game_id = GameId.pokemon
    version = "2024"

    async def fetch(self) -> list[Rule]:
        async with httpx.AsyncClient(timeout=30, follow_redirects=True,
                                     headers={"User-Agent": "Mozilla/5.0"}) as client:
            resp = await client.get(RULES_URL)
            resp.raise_for_status()

        soup = BeautifulSoup(resp.text, "lxml")
        return self._parse(soup)

    def _parse(self, soup: BeautifulSoup) -> list[Rule]:
        rules: list[Rule] = []
        now = datetime.utcnow()
        idx = 0

        for heading in soup.find_all(["h2", "h3", "h4"]):
            title = heading.get_text(strip=True)
            if not title or len(title) < 4:
                continue

            body_parts = []
            for sibling in heading.find_next_siblings():
                if sibling.name in ("h2", "h3", "h4"):
                    break
                text = sibling.get_text(" ", strip=True)
                if text:
                    body_parts.append(text)

            body = " ".join(body_parts)
            if len(body) < 20:
                continue

            idx += 1
            rules.append(Rule(
                id=f"pokemon-sec-{idx:03d}",
                game=GameId.pokemon,
                title=title,
                category=self._infer_category(title),
                body=body,
                language="en",
                version=self.version,
                search_keywords=self._keywords(title, body),
                examples=[],
                last_updated=now,
            ))

        return rules

    def _infer_category(self, title: str) -> str:
        t = title.lower()
        if any(k in t for k in ("turn", "phase")):
            return "Turn Structure"
        if any(k in t for k in ("prize", "win", "lose")):
            return "Win Conditions"
        if any(k in t for k in ("attack", "damage", "knock")):
            return "Combat"
        if any(k in t for k in ("energy", "attach")):
            return "Energy"
        if any(k in t for k in ("evolv", "basic", "stage")):
            return "Pokémon Cards"
        if any(k in t for k in ("trainer", "item", "supporter", "stadium")):
            return "Trainer Cards"
        if any(k in t for k in ("special condition", "poison", "burn", "sleep", "confus", "paralyz")):
            return "Special Conditions"
        return "General"
