# Flesh and Blood
# La página tiene un índice con enlaces a cada versión del reglamento
# Primero busco el enlace a la versión más reciente y luego hago scraping de esa
# URL índice: https://fabtcg.com/resources/rules-and-policy-center/comprehensive-rules/

import httpx
from bs4 import BeautifulSoup
from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

INDEX_URL = "https://fabtcg.com/resources/rules-and-policy-center/comprehensive-rules/"

# Headers que imitan un navegador real para que fabtcg.com no nos bloquee con 403
BROWSER_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
}


class FabScraper(BaseScraper):
    game_id = GameId.fab
    version = "2.4"

    async def fetch(self) -> list[Rule]:
        # Le doy más tiempo porque la página puede tardar en cargar
        async with httpx.AsyncClient(timeout=60, follow_redirects=True,
                                     headers=BROWSER_HEADERS) as client:
            # Primero busco el enlace al reglamento actual en el índice
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
                # Me quedo con el primero que tenga número de versión en la URL
                if any(c.isdigit() for c in href):
                    base = "https://fabtcg.com"
                    return href if href.startswith("http") else base + href
        return None

    def _parse(self, soup: BeautifulSoup) -> list[Rule]:
        rules: list[Rule] = []
        now = datetime.utcnow()
        idx = 0

        # El reglamento usa headings numerados tipo "1. Game Overview" o "2.1 Turn Structure"
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
                # Si el bloque tiene clase "example" lo meto en ejemplos, no en el cuerpo
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
