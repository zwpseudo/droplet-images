#!/bin/bash

echo "Waiting for Docker daemon to be ready..."
TIMEOUT=300  # 5 minutes timeout
ELAPSED=0

while ! docker info > /dev/null 2>&1; do
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "Timeout waiting for Docker daemon"
        exit 1
    fi
    echo "Docker not ready yet, waiting... ($ELAPSED seconds elapsed)"
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

echo "Docker is ready!"
echo ""

# Run the build script
./build-and-push-all.sh latest true
