import hashlib
import os
from flask import Flask, jsonify

app = Flask(__name__)

SECRET_FILE = os.getenv(
    "SECRET_FILE",
    "/mnt/secrets-store/demo-api-key",
)


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/secret-status")
def secret_status():
    try:
        with open(SECRET_FILE, "rb") as secret_file:
            secret = secret_file.read().strip()

        fingerprint = hashlib.sha256(secret).hexdigest()[:12]

        return jsonify(
            secret_loaded=True,
            fingerprint=fingerprint,
        )

    except FileNotFoundError:
        return jsonify(
            secret_loaded=False,
            error="secret file not found",
        ), 503

    except Exception:
        return jsonify(
            secret_loaded=False,
            error="unable to read secret",
        ), 500
