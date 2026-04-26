"""
Flesh and Blood — Comprehensive Rulebook oficial
Fuente: https://fabtcg.com/resources/rules-and-policy-center/comprehensive-rules/
La página lista versiones del reglamento como HTML navegable.
"""
import httpx
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

INDEX_URL = "https://fabtcg.com/resources/rules-and-policy-center/comprehensive-rules/"


class FabScraper(BaseScraper):
    game_id = GameId.fab
    version = "2.4"

    async def fetch(self) -> list[Rule]:
        async with httpx.AsyncClient(timeout=60, follow_redirects=True,
                                     headers={"User-Agent": "Mozilla/5.0"}) as client:
            # Obtener el índice para encontrar el enlace al reglamento actual
            index_resp = await client.get(INDEX_URL)
            index_resp.raise_for_status()
            rulebook_url = self._find_rulebook_link(index_resp.text) or INDEX_URL

            resp = await client.get(rulebook_url)
            resp.raise_for_status()

        soup = BeautifulSoup(resp.text, "lxml")
        return self._parse(soup)

    def _find_rulebook_link(self, html: str) -> str | None:
        soup = BeautifulSoup(html, "lxml")
        for a in soup.find_all("a", href=True):
            href = a["href"]
            if "comprehensive-rules" in href and href.endswith("/"):
                # Preferir la versión más reciente (la primera con número de versión)
                if any(c.isdigit() for c in href):
                    base = "https://fabtcg.com"
                    return href if href.startswith("http") else base + href
        return None

    def _parse(self, soup: BeautifulSoup) -> list[Rule]:
        rules: list[Rule] = []
        now = datetime.utcnow()
        idx = 0

        # El reglamento de FAB usa headers numerados: "1. Game Overview", "2.1 Turn Structure"
        for heading in soup.find_all(["h1", "h2", "h3", "h4"]):
            title = heading.get_text(strip=True)
            if not title or len(title) < 4:
                continue

            body_parts = []
            examples: list[str] = []
            for sibling in heading.find_next_siblings():
                if sibling.name in ("h1", "h2", "h3", "h4"):
                    break
                text = sibling.get_text(" ", strip=True)
                if not text:
                    continue
                # Detectar bloques de ejemplo
                if sibling.get("class") and "example" in " ".join(sibling.get("class", [])):
                    examples.append(text)
                else:
                    body_parts.append(text)

            body = " ".join(body_parts)
            if len(body) < 20:
                continue

            idx += 1
            rules.append(Rule(
                id=f"fab-sec-{idx:03d}",
                game=GameId.fab,
                title=title,
                category=self._infer_category(title),
                body=body,
                language="en",
                version=self.version,
                search_keywords=self._keywords(title, body),
                examples=examples,
                last_updated=now,
            ))

        return rules

    def _infer_category(self, title: str) -> str:
        t = title.lower()
        if any(k in t for k in ("combat", "attack", "defense", "block")):
            return "Combat"
        if any(k in t for k in ("chain", "link", "react")):
            return "Chain Links"
        if any(k in t for k in ("hero", "class", "talent")):
            return "Heroes"
        if any(k in t for k in ("equipment", "weapon", "armor")):
            return "Equipment"
        if any(k in t for k in ("action", "instant", "pitch")):
            return "Card Play"
        if any(k in t for k in ("turn", "phase", "step")):
            return "Turn Structure"
        if any(k in t for k in ("keyword", "aura", "buff", "ephemeral")):
            return "Keywords"
        if any(k in t for k in ("resource", "pitch", "cost")):
            return "Resources"
        return "General"
