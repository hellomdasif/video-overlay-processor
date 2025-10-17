#!/usr/bin/env bash
# Batch process multiple videos with the same settings

# Configuration
CAPTION="[VIEWS] Amazing Content!"
MIN_VIEWS=10
MAX_VIEWS=100
PLACEMENT="top-right"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Process all MP4 files in input directory
for video in "${SCRIPT_DIR}/input"/*.mp4; do
  # Skip if no files match
  [ -e "$video" ] || continue

  # Get filename without path and extension
  filename=$(basename "$video" .mp4)

  echo "Processing: $filename"

  # Run the script
  "${SCRIPT_DIR}/views.sh" \
    --caption-text "$CAPTION" \
    --rand-min "$MIN_VIEWS" \
    --rand-max "$MAX_VIEWS" \
    --placement "$PLACEMENT" \
    "$filename.mp4" \
    "${filename}_processed.mp4"

  echo "Completed: ${filename}_processed.mp4"
  echo "---"
done

echo "All videos processed!"
