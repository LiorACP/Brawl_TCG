from abc import ABC, abstractmethod
from models.rule import Rule


class BaseScraper(ABC):
    game_id: str
    version: str = "1.0"
    language: str = "es"

    @abstractmethod
    async def fetch(self) -> list[Rule]:
        """Descarga y normaliza las reglas. Devuelve lista de Rule."""
        ...

    def _keywords(self, *texts: str) -> list[str]:
        """Extrae palabras únicas de más de 3 caracteres como keywords."""
        seen = set()
        for text in texts:
            for word in text.lower().split():
                clean = word.strip(".,;:()")
                if len(clean) > 3:
                    seen.add(clean)
        return list(seen)[:30]
