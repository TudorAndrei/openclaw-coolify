#!/bin/bash
set -e

# Inherit DOCKER_HOST if set, or default to socket proxy
export DOCKER_HOST="${DOCKER_HOST:-tcp://docker-proxy:2375}"

echo "🦞 Building OpenClaw Sandbox Base Image..."

# Use Astral uv image so Python comes from uv-managed runtime
BASE_IMAGE="${OPENCLAW_SANDBOX_BASE_IMAGE:-ghcr.io/astral-sh/uv:python3.12-bookworm-slim}"
TARGET_IMAGE="openclaw-sandbox:bookworm-slim"

# Check if image already exists
if docker image inspect "$TARGET_IMAGE" >/dev/null 2>&1; then
	if [ "${OPENCLAW_SANDBOX_FORCE_REBUILD:-0}" = "1" ]; then
		echo "   Removing existing image for forced rebuild: $TARGET_IMAGE"
		docker image rm "$TARGET_IMAGE" >/dev/null 2>&1 || true
	elif [ "${OPENCLAW_SANDBOX_ENSURE_UV:-1}" = "1" ]; then
		if ! docker run --rm --entrypoint sh "$TARGET_IMAGE" -lc 'command -v uv >/dev/null 2>&1 && python3 -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 12) else 1)"' >/dev/null 2>&1; then
			echo "   Existing image is missing uv or Python >= 3.12. Rebuilding: $TARGET_IMAGE"
			docker image rm "$TARGET_IMAGE" >/dev/null 2>&1 || true
		else
			echo "✅ Sandbox base image already exists: $TARGET_IMAGE"
			exit 0
		fi
	else
		echo "✅ Sandbox base image already exists: $TARGET_IMAGE"
		echo "   Set OPENCLAW_SANDBOX_FORCE_REBUILD=1 to rebuild from $BASE_IMAGE"
		exit 0
	fi
fi

echo "   Pulling $BASE_IMAGE..."
docker pull "$BASE_IMAGE"

echo "   Tagging as $TARGET_IMAGE..."
docker tag "$BASE_IMAGE" "$TARGET_IMAGE"

echo "✅ Sandbox base image ready: $TARGET_IMAGE"
