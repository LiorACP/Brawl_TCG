from fastapi import APIRouter
from pydantic import BaseModel
from firebase_admin import messaging
from db.firestore_client import get_db

router = APIRouter(prefix="/notify", tags=["Notifications"])


class EnrollmentPayload(BaseModel):
    organizer_uid: str
    player_name: str
    tournament_name: str
    tournament_id: str


@router.post("/enrollment", summary="Envía push FCM al organizador cuando alguien se inscribe")
async def notify_enrollment(payload: EnrollmentPayload):
    db = get_db()

    user_doc = db.collection("User").document(payload.organizer_uid).get()
    if not user_doc.exists:
        return {"status": "organizer_not_found"}

    fcm_token = user_doc.to_dict().get("fcmToken")
    if not fcm_token:
        return {"status": "no_token"}

    msg = messaging.Message(
        notification=messaging.Notification(
            title="Nueva inscripción ✉",
            body=f"{payload.player_name} quiere apuntarse a {payload.tournament_name}",
        ),
        data={
            "type": "inscripcion",
            "tournamentId": payload.tournament_id,
        },
        token=fcm_token,
    )

    try:
        messaging.send(msg)
        return {"status": "sent"}
    except messaging.UnregisteredError:
        # El token ya no es válido, lo limpiamos de Firestore
        db.collection("User").document(payload.organizer_uid).update({"fcmToken": ""})
        return {"status": "token_expired"}
    except Exception as e:
        return {"status": "error", "detail": str(e)}
