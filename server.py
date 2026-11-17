import os
import uuid
from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from livekit import api

load_dotenv()

LIVEKIT_URL = os.getenv("LIVEKIT_URL")
LIVEKIT_API_KEY = os.getenv("LIVEKIT_API_KEY")
LIVEKIT_API_SECRET = os.getenv("LIVEKIT_API_SECRET")

app = FastAPI()
INDEX = Path(__file__).parent / "index.html"


@app.get("/")
async def index():
    return FileResponse(INDEX)


@app.get("/api/token")
async def token():
    if not (LIVEKIT_URL and LIVEKIT_API_KEY and LIVEKIT_API_SECRET):
        raise HTTPException(
            status_code=500,
            detail="Set LIVEKIT_URL, LIVEKIT_API_KEY and LIVEKIT_API_SECRET in .env",
        )

    # A fresh room per session means the agent worker is dispatched to it automatically.
    room_name = f"jarvis-{uuid.uuid4().hex[:8]}"
    identity = f"kavishankar-{uuid.uuid4().hex[:6]}"

    jwt = (
        api.AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET)
        .with_identity(identity)
        .with_name("Kavishankar")
        .with_grants(api.VideoGrants(room_join=True, room=room_name))
        .to_jwt()
    )
    return {"token": jwt, "url": LIVEKIT_URL, "room": room_name}


if __name__ == "__main__":
    import uvicorn

    print("Open this in Chrome or Edge: http://localhost:8000")
    uvicorn.run(app, host="127.0.0.1", port=8000)
    