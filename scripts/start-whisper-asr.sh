#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/config/docker-compose.asr.example.yml"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required but was not found." >&2
  exit 1
fi

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

echo "Starting Whisper ASR service (this will download the model on first run)..."
docker compose -f "$COMPOSE_FILE" up -d

echo "Whisper ASR service is starting on http://localhost:9000"
