"""
Disney Lorcana — Scraping del reglamento oficial de Ravensburger
Fuente: https://www.disneylorcana.com/en-US/resources
El PDF/HTML de reglas está disponible públicamente.
"""
import httpx
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

RULES_URL = "https://www.disneylorcana.com/en-US/resources"
# Fallback: la FAQ estructurada también sirve como fuente de reglas
FAQ_URL = "https://www.disneylorcana.com/en-US/faq"


class LorcanaScraper(BaseScraper):
    game_id = GameId.lorcana
    version = "2024"

    async def fetch(self) -> list[Rule]:
        async with httpx.AsyncClient(timeout=30, follow_redirects=True,
                                     headers={"User-Agent": "Mozilla/5.0"}) as client:
            resp = await client.get(RULES_URL)
            resp.raise_for_status()
            soup = BeautifulSoup(resp.text, "lxml")

        rules = self._parse(soup)

        # Si no se extrajo nada útil de resources, intentar con FAQ
        if len(rules) < 3:
            resp2 = await client.get(FAQ_URL)
            if resp2.status_code == 200:
                soup2 = BeautifulSoup(resp2.text, "lxml")
                rules = self._parse_faq(soup2)

        return rules

    def _parse(self, soup: BeautifulSoup) -> list[Rule]:
        rules: list[Rule] = []
        now = datetime.utcnow()
        idx = 0

        for heading in soup.find_all(["h2", "h3"]):
            title = heading.get_text(strip=True)
            if not title or len(title) < 4:
                continue

            body_parts = []
            for sibling in heading.find_next_siblings():
                if sibling.name in ("h2", "h3"):
                    break
                text = sibling.get_text(" ", strip=True)
                if text:
                    body_parts.append(text)

            body = " ".join(body_parts)
            if len(body) < 20:
                continue

            idx += 1
            rules.append(Rule(
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
            ))

        return rules

    def _parse_faq(self, soup: BeautifulSoup) -> list[Rule]:
        rules: list[Rule] = []
        now = datetime.utcnow()
        idx = 0

        # FAQs suelen estar en pares pregunta/respuesta con dt/dd o summary/p
        for item in soup.find_all(["details", "div"], class_=lambda c: c and "faq" in c.lower()):
            question = item.find(["summary", "dt", "h3", "h4"])
            answer = item.find(["p", "dd"])
            if not question or not answer:
                continue

            title = question.get_text(strip=True)
            body = answer.get_text(" ", strip=True)
            if len(body) < 10:
                continue

            idx += 1
            rules.append(Rule(
                id=f"lorcana-faq-{idx:03d}",
                game=GameId.lorcana,
                title=title,
                category="FAQ",
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
        if any(k in t for k in ("sing", "song")):
            return "Songs"
        if any(k in t for k in ("quest", "location")):
            return "Questing & Locations"
        if any(k in t for k in ("challenge", "banish")):
            return "Challenging"
        if any(k in t for k in ("ink", "inkable")):
            return "Ink & Costs"
        if any(k in t for k in ("shift", "play")):
            return "Playing Cards"
        if any(k in t for k in ("ability", "keyword")):
            return "Keywords & Abilities"
        return "General"
