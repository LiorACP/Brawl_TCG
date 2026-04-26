from fastapi import APIRouter, HTTPException, Query
from models.rule import Rule, RuleCreate, RuleUpdate, GameId
from db.firestore_client import upsert_rule, get_rule, list_rules, delete_rule, search_rules
from datetime import datetime

router = APIRouter(prefix="/rules", tags=["Rules"])


@router.get(
    "/{game}",
    response_model=list[Rule],
    summary="Listar reglas de un juego",
)
async def get_rules(
    game: GameId,
    category: str | None = Query(None, description="Filtrar por categoría"),
    language: str | None = Query(None, description="Filtrar por idioma (ej: es, en)"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
):
    docs = await list_rules(game.value, category=category, language=language,
                             limit=limit, offset=offset)
    return docs


@router.get(
    "/{game}/search",
    response_model=list[Rule],
    summary="Buscar reglas por texto",
)
async def search(
    game: GameId,
    q: str = Query(..., min_length=2, description="Término de búsqueda"),
    limit: int = Query(20, ge=1, le=100),
):
    return await search_rules(game.value, q, limit=limit)


@router.get(
    "/{game}/{rule_id}",
    response_model=Rule,
    summary="Obtener una regla por ID",
)
async def get_one(game: GameId, rule_id: str):
    doc = await get_rule(game.value, rule_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Regla no encontrada")
    return doc


@router.post(
    "/{game}",
    response_model=Rule,
    status_code=201,
    summary="Crear una regla manualmente",
)
async def create_rule(game: GameId, body: RuleCreate):
    if body.game != game:
        raise HTTPException(status_code=400, detail="El campo 'game' no coincide con la ruta")
    data = body.model_dump()
    data["last_updated"] = datetime.utcnow()
    await upsert_rule(game.value, body.id, data)
    return {**data}


@router.patch(
    "/{game}/{rule_id}",
    response_model=Rule,
    summary="Actualizar campos de una regla",
)
async def update_rule(game: GameId, rule_id: str, body: RuleUpdate):
    existing = await get_rule(game.value, rule_id)
    if not existing:
        raise HTTPException(status_code=404, detail="Regla no encontrada")
    updates = body.model_dump(exclude_none=True)
    updates["last_updated"] = datetime.utcnow()
    merged = {**existing, **updates}
    await upsert_rule(game.value, rule_id, merged)
    return merged


@router.delete(
    "/{game}/{rule_id}",
    status_code=204,
    summary="Eliminar una regla",
)
async def remove_rule(game: GameId, rule_id: str):
    deleted = await delete_rule(game.value, rule_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Regla no encontrada")
