#!/bin/bash
set -e

# Inherit DOCKER_HOST if set, or default to socket proxy
export DOCKER_HOST="${DOCKER_HOST:-tcp://docker-proxy:2375}"

echo "🦞 Building OpenClaw Sandbox Browser Image..."

# Use playwright image for browser capabilities
BASE_IMAGE="${OPENCLAW_SANDBOX_BROWSER_BASE_IMAGE:-mcr.microsoft.com/playwright:v1.41.0-jammy}"
TARGET_IMAGE="openclaw-sandbox-browser:bookworm-slim"

# Check if image already exists
if docker image inspect "$TARGET_IMAGE" >/dev/null 2>&1; then
	if [ "${OPENCLAW_SANDBOX_BROWSER_FORCE_REBUILD:-0}" = "1" ]; then
		echo "   Removing existing image for forced rebuild: $TARGET_IMAGE"
		docker image rm "$TARGET_IMAGE" >/dev/null 2>&1 || true
	else
		echo "✅ Sandbox browser image already exists: $TARGET_IMAGE"
		echo "   Set OPENCLAW_SANDBOX_BROWSER_FORCE_REBUILD=1 to rebuild from $BASE_IMAGE"
		exit 0
	fi
fi

echo "   Pulling $BASE_IMAGE..."
docker pull "$BASE_IMAGE"

echo "   Tagging as $TARGET_IMAGE..."
docker tag "$BASE_IMAGE" "$TARGET_IMAGE"

echo "✅ Sandbox browser image ready: $TARGET_IMAGE"
