from fastapi import APIRouter, BackgroundTasks, HTTPException
from models.rule import IngestResponse, GameId
from db.firestore_client import upsert_rule
from scrapers.magic_scraper import MagicScraper
from scrapers.yugioh_scraper import YugiohScraper
from scrapers.pokemon_scraper import PokemonScraper
from scrapers.lorcana_scraper import LorcanaScraper
from scrapers.fab_scraper import FabScraper
from scrapers.onepiece_scraper import OnePieceScraper

router = APIRouter(prefix="/ingest", tags=["Ingest"])

SCRAPERS = {
    GameId.magic: MagicScraper,
    GameId.yugioh: YugiohScraper,
    GameId.pokemon: PokemonScraper,
    GameId.lorcana: LorcanaScraper,
    GameId.fab: FabScraper,
    GameId.onepiece: OnePieceScraper,
}


async def _run_ingest(game: GameId) -> IngestResponse:
    scraper_cls = SCRAPERS[game]
    scraper = scraper_cls()

    try:
        rules = await scraper.fetch()
    except Exception as e:
        return IngestResponse(
            game=game.value,
            inserted=0,
            updated=0,
            errors=1,
            message=f"Error al obtener datos: {e}",
        )

    inserted = updated = errors = 0
    for rule in rules:
        try:
            data = rule.model_dump()
            # Convertir datetime a string ISO para Firestore
            if data.get("last_updated"):
                data["last_updated"] = data["last_updated"].isoformat()
            was_new = await upsert_rule(game.value, rule.id, data)
            if was_new:
                inserted += 1
            else:
                updated += 1
        except Exception:
            errors += 1

    return IngestResponse(
        game=game.value,
        inserted=inserted,
        updated=updated,
        errors=errors,
        message=f"Ingesta completada: {inserted} nuevas, {updated} actualizadas, {errors} errores.",
    )


@router.post(
    "/{game}",
    response_model=IngestResponse,
    summary="Lanzar ingesta para un juego concreto",
    description=(
        "Descarga, normaliza y sincroniza las reglas del juego indicado "
        "con Firestore. Proceso síncrono (espera hasta completar)."
    ),
)
async def ingest_game(game: GameId):
    return await _run_ingest(game)


@router.post(
    "/all",
    response_model=list[IngestResponse],
    summary="Lanzar ingesta para todos los juegos",
)
async def ingest_all():
    results = []
    for game in GameId:
        result = await _run_ingest(game)
        results.append(result)
    return results


@router.post(
    "/{game}/background",
    status_code=202,
    summary="Lanzar ingesta en background (no bloquea)",
)
async def ingest_background(game: GameId, background_tasks: BackgroundTasks):
    async def _task():
        await _run_ingest(game)

    background_tasks.add_task(_task)
    return {"message": f"Ingesta de '{game.value}' iniciada en background."}
