from abc import ABC, abstractmethod
from models.rule import Rule


class BaseScraper(ABC):
    game_id: str
    version: str = "1.0"
    language: str = "es"

    @abstractmethod
    async def fetch(self) -> list[Rule]:
        # Cada scraper implementa esto a su manera según la fuente de datos
        ...

    def _keywords(self, *texts: str) -> list[str]:
        # Saco palabras de más de 3 letras para usarlas como palabras clave de búsqueda
        seen = set()
        for text in texts:
            for word in text.lower().split():
                clean = word.strip(".,;:()")
                if len(clean) > 3:
                    seen.add(clean)
        return list(seen)[:30]
