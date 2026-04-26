import firebase_admin
from firebase_admin import credentials, firestore
from config import settings

# Solo se inicializa una vez, si se llamara varias veces petalería
_app: firebase_admin.App | None = None


def get_db() -> firestore.Client:
    global _app
    if _app is None:
        cred = credentials.Certificate(settings.google_application_credentials)
        _app = firebase_admin.initialize_app(cred, {
            "projectId": settings.firestore_project_id,
        })
    return firestore.client()


# Nombres de las colecciones para no escribirlos a mano en cada sitio
GAMES_COL = "games"
RULES_COL = "rules"


def rules_ref(game: str):
    db = get_db()
    return db.collection(GAMES_COL).document(game).collection(RULES_COL)


async def upsert_rule(game: str, rule_id: str, data: dict) -> bool:
    # Devuelve True si era nueva, False si ya existía y la hemos actualizado
    ref = rules_ref(game).document(rule_id)
    doc = ref.get()
    ref.set(data, merge=True)
    return not doc.exists


async def get_rule(game: str, rule_id: str) -> dict | None:
    doc = rules_ref(game).document(rule_id).get()
    return doc.to_dict() if doc.exists else None


async def list_rules(
    game: str,
    category: str | None = None,
    language: str | None = None,
    limit: int = 50,
    offset: int = 0,
) -> list[dict]:
    query = rules_ref(game)
    if category:
        query = query.where("category", "==", category)
    if language:
        query = query.where("language", "==", language)
    docs = query.limit(limit).offset(offset).stream()
    return [d.to_dict() for d in docs]


async def delete_rule(game: str, rule_id: str) -> bool:
    ref = rules_ref(game).document(rule_id)
    if not ref.get().exists:
        return False
    ref.delete()
    return True


async def search_rules(game: str, q: str, limit: int = 20) -> list[dict]:
    # Firestore no tiene búsqueda de texto completo, así que lo hago a mano
    q_lower = q.lower()
    docs = rules_ref(game).stream()
    results = []
    for doc in docs:
        data = doc.to_dict()
        keywords: list = data.get("search_keywords", [])
        title: str = data.get("title", "").lower()
        body: str = data.get("body", "").lower()
        if (
            q_lower in title
            or q_lower in body
            or any(q_lower in kw.lower() for kw in keywords)
        ):
            results.append(data)
        if len(results) >= limit:
            break
    return results
