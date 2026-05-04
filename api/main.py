from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import rules, ingest, notify

app = FastAPI(
    title="TCG Rules API",
    description=(
        "API de ingesta y consulta de reglas para juegos de cartas coleccionables.\n\n"
        "**Juegos soportados:** Magic: The Gathering · Pokémon TCG · Yu-Gi-Oh! · "
        "Flesh and Blood · Disney Lorcana · One Piece TCG\n\n"
        "**Base de datos:** Google Cloud Firestore\n\n"
        "Desarrollado como parte del TFG Brawl TCG."
    ),
    version="1.0.0",
    contact={"name": "Lior", "email": "liorcruz2002@gmail.com"},
    license_info={"name": "MIT"},
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(rules.router)
app.include_router(ingest.router)
app.include_router(notify.router)


@app.get("/", tags=["Health"], summary="Estado del servicio")
async def root():
    return {
        "status": "ok",
        "docs": "/docs",
        "games": ["magic", "yugioh", "pokemon", "lorcana", "fab", "onepiece"],
    }


@app.get("/health", tags=["Health"], summary="Health check")
async def health():
    return {"status": "healthy"}
