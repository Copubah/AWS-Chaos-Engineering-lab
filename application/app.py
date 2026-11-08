from flask import Flask, jsonify
import socket
import os
import datetime

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "project": "AWS ResilienceLab",
        "status": "running",
        "instance": socket.gethostname(),
        "timestamp": datetime.datetime.now(
            datetime.timezone.utc
        ).isoformat()
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "instance": socket.gethostname()
    }), 200


@app.route("/failure")
def failure():
    return jsonify({
        "status": "simulated_failure",
        "message": "This endpoint will support chaos experiments."
    }), 500


@app.route("/metrics")
def metrics():
    return jsonify({
        "application": "ResilienceLab",
        "hostname": socket.gethostname(),
        "environment": os.getenv("ENVIRONMENT", "development")
    })


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000
    )
