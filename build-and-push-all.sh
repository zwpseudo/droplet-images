#!/bin/bash

# Build and push all droplet images to ghcr.io
# Removed set -e to allow script to continue on errors

REGISTRY="ghcr.io/zwpseudo"
TAG="${1:-latest}"
SKIP_EXISTING="${2:-false}"

echo "Building and pushing all images with tag: $TAG"
echo "Registry: $REGISTRY"
echo "Skip existing: $SKIP_EXISTING"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0
SKIPPED_COUNT=0
FAILED_IMAGES=()

# Find all dockerfile-* files
for dockerfile in dockerfile-*; do
    # Extract the image name from the filename (remove 'dockerfile-' prefix)
    IMAGE_NAME="${dockerfile#dockerfile-}"
    FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${TAG}"
    
    # Check if image already exists in registry
    if [ "$SKIP_EXISTING" = "true" ]; then
        if docker manifest inspect "$FULL_IMAGE_NAME" > /dev/null 2>&1; then
            echo "⊙ Skipping $IMAGE_NAME (already exists)"
            ((SKIPPED_COUNT++))
            continue
        fi
    fi
    
    echo "=================================================="
    echo "Building: $IMAGE_NAME"
    echo "Full image: $FULL_IMAGE_NAME"
    echo "=================================================="
    
    # Build the image
    if docker build -f "$dockerfile" -t "$FULL_IMAGE_NAME" --build-arg BASE_TAG="$TAG" .; then
        # Push the image
        echo "Pushing: $FULL_IMAGE_NAME"
        if docker push "$FULL_IMAGE_NAME"; then
            echo "✓ Successfully built and pushed: $FULL_IMAGE_NAME"
            ((SUCCESS_COUNT++))
        else
            echo "✗ Failed to push: $FULL_IMAGE_NAME"
            FAILED_IMAGES+=("$IMAGE_NAME (push failed)")
            ((FAIL_COUNT++))
        fi
    else
        echo "✗ Failed to build: $FULL_IMAGE_NAME"
        FAILED_IMAGES+=("$IMAGE_NAME (build failed)")
        ((FAIL_COUNT++))
    fi
    
    echo ""
done

echo "=================================================="
echo "Build Summary"
echo "=================================================="
echo "Successfully built and pushed: $SUCCESS_COUNT"
echo "Skipped (already exist): $SKIPPED_COUNT"
echo "Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -gt 0 ]; then
    echo ""
    echo "Failed images:"
    for img in "${FAILED_IMAGES[@]}"; do
        echo "  - $img"
    done
    exit 1
fi

echo "=================================================="
echo "All images processed successfully!"
echo "=================================================="
