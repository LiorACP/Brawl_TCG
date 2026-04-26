from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum


class GameId(str, Enum):
    magic = "magic"
    yugioh = "yugioh"
    pokemon = "pokemon"
    lorcana = "lorcana"
    fab = "fab"
    onepiece = "onepiece"


class Rule(BaseModel):
    id: str
    game: GameId
    title: str
    category: str
    body: str
    language: str = "es"
    version: str = "1.0"
    search_keywords: List[str] = []
    examples: List[str] = []
    last_updated: Optional[datetime] = Field(default_factory=datetime.utcnow)


class RuleCreate(BaseModel):
    id: str
    game: GameId
    title: str
    category: str
    body: str
    language: str = "es"
    version: str = "1.0"
    search_keywords: List[str] = []
    examples: List[str] = []


class RuleUpdate(BaseModel):
    title: Optional[str] = None
    category: Optional[str] = None
    body: Optional[str] = None
    language: Optional[str] = None
    version: Optional[str] = None
    search_keywords: Optional[List[str]] = None
    examples: Optional[List[str]] = None


class IngestResponse(BaseModel):
    game: str
    inserted: int
    updated: int
    errors: int
    message: str
