# =============================================================================
# YouTube Stream Extractor (yt-dlp + tiny Ruby API), own container
# Extracts audio, video, or metadata — not audio-only, despite the old name.
# =============================================================================

COMPOSE_FILE := ./docker/docker-compose.yml
YOUTUBE_STREAM_PORT ?= 4567
WANT ?= audio

# Build the service image
youtube-stream-build:
	docker compose -f $(COMPOSE_FILE) build youtube_stream

# Start the service (builds first if the image doesn't exist yet)
youtube-stream-start:
	docker compose -f $(COMPOSE_FILE) up -d youtube_stream

# Stop the service
youtube-stream-stop:
	docker compose -f $(COMPOSE_FILE) stop youtube_stream

# Rebuild + restart — run this after editing server.rb or the Dockerfile
youtube-stream-restart:
	make youtube-stream-stop
	make youtube-stream-build
	make youtube-stream-start

# Tail logs
youtube-stream-logs:
	docker compose -f $(COMPOSE_FILE) logs -f youtube_stream

# Shell into the running container
youtube-stream-shell:
	docker compose -f $(COMPOSE_FILE) exec youtube_stream bash

# Health check from the host
youtube-stream-health:
	curl -sf http://localhost:$(YOUTUBE_STREAM_PORT)/health && echo

# Extract from a YouTube URL:
#   make youtube-stream-extract URL=https://youtu.be/XXXXXXXXXXX
#   make youtube-stream-extract URL=https://youtu.be/XXXXXXXXXXX WANT=metadata
#   make youtube-stream-extract URL=https://youtu.be/XXXXXXXXXXX WANT=video
# Response is JSON: { "type": "audio", "filename": "<id>.mp3" }
# The file itself lands in the shared volume, readable from Rails at
# storage/youtube_stream/<filename>.
youtube-stream-extract:
	@test -n "$(URL)" || (echo "Usage: make youtube-stream-extract URL=<youtube-url> [WANT=audio|metadata|video]"; exit 1)
	curl -s -X POST http://localhost:$(YOUTUBE_STREAM_PORT)/extract \
	  -H "Content-Type: application/json" \
	  -d '{"url": "$(URL)", "want": "$(WANT)"}'
	@echo

# Help for YouTube Stream Extractor commands
youtube-stream-help:
	@echo "=============================================================="
	@echo "YouTube Stream Extractor commands:"
	@echo "=============================================================="
	@echo "  make youtube-stream-build             - Build the service image"
	@echo "  make youtube-stream-start             - Start the service"
	@echo "  make youtube-stream-stop              - Stop the service"
	@echo "  make youtube-stream-restart           - Rebuild + restart (after code changes)"
	@echo "  make youtube-stream-logs              - Tail logs"
	@echo "  make youtube-stream-shell             - Shell into the container"
	@echo "  make youtube-stream-health            - Health check"
	@echo "  make youtube-stream-extract URL=<url> [WANT=audio|metadata|video]"
	@echo "=============================================================="
