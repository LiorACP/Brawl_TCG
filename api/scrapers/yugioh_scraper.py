"""
Yu-Gi-Oh! — YGOPRODECK Rules endpoint + scraping del reglamento oficial
Fuente HTML: https://www.yugioh-card.com/en/rulebook/
"""
import httpx
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

RULEBOOK_URL = "https://www.yugioh-card.com/en/rulebook/"


class YugiohScraper(BaseScraper):
    game_id = GameId.yugioh
    version = "2024"

    async def fetch(self) -> list[Rule]:
        async with httpx.AsyncClient(timeout=30, follow_redirects=True) as client:
            resp = await client.get(RULEBOOK_URL)
            resp.raise_for_status()

        soup = BeautifulSoup(resp.text, "lxml")
        return self._parse(soup)

    def _parse(self, soup: BeautifulSoup) -> list[Rule]:
        rules: list[Rule] = []
        now = datetime.utcnow()
        idx = 0

        # El reglamento usa h2/h3 como títulos de sección y párrafos como cuerpo
        sections = soup.find_all(["h2", "h3"])
        for section in sections:
            title = section.get_text(strip=True)
            if not title or len(title) < 3:
                continue

            # Acumular párrafos hasta la siguiente sección
            body_parts = []
            for sibling in section.find_next_siblings():
                if sibling.name in ("h2", "h3"):
                    break
                text = sibling.get_text(" ", strip=True)
                if text:
                    body_parts.append(text)

            body = " ".join(body_parts)
            if not body:
                continue

            idx += 1
            rules.append(Rule(
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
            ))

        return rules

    def _infer_category(self, title: str) -> str:
        t = title.lower()
        if any(k in t for k in ("turn", "phase", "step")):
            return "Turn Structure"
        if any(k in t for k in ("monster", "spell", "trap")):
            return "Card Types"
        if any(k in t for k in ("attack", "battle", "damage")):
            return "Battle"
        if any(k in t for k in ("effect", "chain", "resolv")):
            return "Effects & Chains"
        if any(k in t for k in ("special summon", "normal summon", "tribute")):
            return "Summoning"
        return "General"
