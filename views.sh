#!/usr/bin/env bash
set -euo pipefail

prog="$(basename "$0")"

usage() {
  cat >&2 <<EOF
Usage:
  $prog [OPTIONS] INPUT OUT

Positional:
  INPUT         : input identifier. Can be:
                    - relative path like "KnowSparkz/yH0c5RkJlQ4.mp4"  (resolves to INPUT_BASE/<relpath>)
                    - full URL like "https://host/KnowSparkz/yH0c5RkJlQ4.mp4" (host stripped)
                    - absolute path like "/files/KnowSparkz/.../file.mp4" (used as-is)
  OUT           : output path or basename. If OUT contains '/', it's used verbatim.
                  If OUT is just a filename (no '/'):
                    - if --output-dir given -> OUT is written as --output-dir/OUT
                    - else -> OUT is written as --assets-dir/OUT

Directory Options:
  --assets-dir DIR       : Folder for assets (font, eye.png, emoji.png) and temp files
                           Default: /files/extra
  --input-base DIR       : Base folder for relative inputs and URL-stripped paths
                           Default: /files
  --output-dir DIR       : Optional target folder for outputs when OUT is a basename
                           Default: (none)

Toggle Options:
  --no-screenshot        : Disable screenshot overlay (view count thumbnail)
  --no-caption           : Disable caption bar overlay
  --no-emoji             : Disable emoji overlay
  --overlay-only         : Only apply overlays without screenshot (caption + emoji only)

View Count Overlay Options:
  --placement POS        : Screenshot position (top-right|top-left|bottom-right|bottom-left)
                           Default: top-right
  --icon-anchor POS      : Eye icon anchor (top-right|top-left|bottom-right|bottom-left)
                           Default: bottom-left
  --icon-size SIZE       : Eye icon size in pixels
                           Default: 64
  --icon-offset-x OFFSET : Eye icon X offset (pixels or percentage like "4%")
                           Default: 4%
  --icon-offset-y OFFSET : Eye icon Y offset (pixels or percentage like "4%")
                           Default: 4%
  --text-gap GAP         : Gap between icon and text in pixels
                           Default: 6
  --font-size SIZE       : View count font size in pixels
                           Default: 48
  --text-offset-x OFFSET : Text X offset adjustment in pixels
                           Default: 0
  --text-offset-y OFFSET : Text Y offset adjustment in pixels
                           Default: 0
  --rand-min MIN         : Minimum view count in millions
                           Default: 1
  --rand-max MAX         : Maximum view count in millions
                           Default: 100

Screenshot Overlay Options:
  --overlay-width WIDTH  : Screenshot width (pixels or percentage like "30%")
                           Default: 30%
  --overlay-height HEIGHT: Screenshot height (pixels or percentage like "25%")
                           Default: 25%
  --overlay-offset-x OFF : Screenshot X offset in pixels
                           Default: 20
  --overlay-offset-y OFF : Screenshot Y offset in pixels
                           Default: 110

Caption Bar Options:
  --caption-text TEXT    : Caption text (use [VIEWS] as placeholder for view count)
                           Default: "[VIEWS] Apko Bhi Sikhna Hai To Comment Kro"
  --bar-height HEIGHT    : Caption bar height in pixels
                           Default: 110
  --bar-offset-y OFFSET  : Caption bar Y offset in pixels
                           Default: 0
  --bar-opacity OPACITY  : Caption bar background opacity (0-255)
                           Default: 229
  --caption-font-size SZ : Caption font size in pixels
                           Default: 40

Emoji Overlay Options:
  --emoji-size SIZE      : Emoji size in pixels
                           Default: 74
  --emoji-offset-x OFF   : Emoji X offset in pixels
                           Default: 50
  --emoji-offset-y OFF   : Emoji Y offset in pixels
                           Default: 20

Timing Options:
  --frame-delay SECONDS  : Delay before showing screenshot overlay
                           Default: 0
  --fps FPS              : Output video frame rate
                           Default: 30
  --duration SECONDS     : Maximum output duration (fallback)
                           Default: 600

Other Options:
  --font-file FILENAME   : Font filename (must exist in assets-dir)
                           Default: ARIALBD 1.TTF
  --help                 : Show this help

Examples:
  # Basic usage with default settings
  $prog input.mp4 output.mp4

  # Custom view count range (10M-50M)
  $prog --rand-min 10 --rand-max 50 input.mp4 output.mp4

  # Custom caption text
  $prog --caption-text "[VIEWS] Subscribe for More!" input.mp4 output.mp4

  # Bottom-left screenshot placement with custom size
  $prog --placement bottom-left --overlay-width 40% --overlay-height 30% input.mp4 output.mp4

  # Full customization
  $prog --assets-dir ./assets --caption-text "[VIEWS] Learn More!" \\
        --placement top-left --bar-height 120 --font-size 52 \\
        input.mp4 output.mp4
EOF
}

# ============================================================================
# DEFAULT CONFIGURATION - All variables with their default values
# ============================================================================

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directory defaults (relative to script location)
ASSETS_DIR="${SCRIPT_DIR}/assets"
INPUT_BASE="${SCRIPT_DIR}/input"
OUTPUT_DIR="${SCRIPT_DIR}/output"

# Font configuration (try multiple fonts in assets/fonts)
FONT_FILE="ARIALBD 1.TTF"

# View count overlay defaults
PLACEMENT="top-right"
ICON_ANCHOR="bottom-left"
ICON_SIZE=64
ICON_OFFSET_X="4%"
ICON_OFFSET_Y="4%"
TEXT_GAP=6
FONTSIZE=48
TEXT_OFFSET_X=0
TEXT_OFFSET_Y=0
RAND_MIN=1
RAND_MAX=100

# Screenshot overlay defaults
OVERLAY_W="30%"
OVERLAY_H="25%"
OVERLAY_OFFSET_X=20
OVERLAY_OFFSET_Y=110

# Caption bar defaults
CAPTION_TEXT="[VIEWS] Apko Bhi Sikhna Hai To Comment Kro"
BAR_HEIGHT=110
BAR_OFFSET_Y=0
BAR_BG_OPACITY=229
CAPTION_FONT_SIZE=40

# Emoji overlay defaults
EMOJI_SIZE=74
EMOJI_OFFSET_X=50
EMOJI_OFFSET_Y=20

# Timing defaults
FRAME_DELAY_START=0
FPS=30
DURATION_FALLBACK=600

# Toggle defaults (enable all by default)
ENABLE_SCREENSHOT=true
ENABLE_CAPTION=true
ENABLE_EMOJI=true

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

while [ $# -gt 0 ]; do
  case "$1" in
    # Directory options
    --assets-dir)
      shift; ASSETS_DIR="${1:-}"
      ;;
    --input-base)
      shift; INPUT_BASE="${1:-}"
      ;;
    --output-dir)
      shift; OUTPUT_DIR="${1:-}"
      ;;

    # Font options
    --font-file)
      shift; FONT_FILE="${1:-}"
      ;;

    # Toggle options
    --no-screenshot)
      ENABLE_SCREENSHOT=false
      ;;
    --no-caption)
      ENABLE_CAPTION=false
      ;;
    --no-emoji)
      ENABLE_EMOJI=false
      ;;
    --overlay-only)
      ENABLE_SCREENSHOT=false
      ;;

    # View count overlay options
    --placement)
      shift; PLACEMENT="${1:-}"
      ;;
    --icon-anchor)
      shift; ICON_ANCHOR="${1:-}"
      ;;
    --icon-size)
      shift; ICON_SIZE="${1:-}"
      ;;
    --icon-offset-x)
      shift; ICON_OFFSET_X="${1:-}"
      ;;
    --icon-offset-y)
      shift; ICON_OFFSET_Y="${1:-}"
      ;;
    --text-gap)
      shift; TEXT_GAP="${1:-}"
      ;;
    --font-size)
      shift; FONTSIZE="${1:-}"
      ;;
    --text-offset-x)
      shift; TEXT_OFFSET_X="${1:-}"
      ;;
    --text-offset-y)
      shift; TEXT_OFFSET_Y="${1:-}"
      ;;
    --rand-min)
      shift; RAND_MIN="${1:-}"
      ;;
    --rand-max)
      shift; RAND_MAX="${1:-}"
      ;;

    # Screenshot overlay options
    --overlay-width)
      shift; OVERLAY_W="${1:-}"
      ;;
    --overlay-height)
      shift; OVERLAY_H="${1:-}"
      ;;
    --overlay-offset-x)
      shift; OVERLAY_OFFSET_X="${1:-}"
      ;;
    --overlay-offset-y)
      shift; OVERLAY_OFFSET_Y="${1:-}"
      ;;

    # Caption bar options
    --caption-text)
      shift; CAPTION_TEXT="${1:-}"
      ;;
    --bar-height)
      shift; BAR_HEIGHT="${1:-}"
      ;;
    --bar-offset-y)
      shift; BAR_OFFSET_Y="${1:-}"
      ;;
    --bar-opacity)
      shift; BAR_BG_OPACITY="${1:-}"
      ;;
    --caption-font-size)
      shift; CAPTION_FONT_SIZE="${1:-}"
      ;;

    # Emoji overlay options
    --emoji-size)
      shift; EMOJI_SIZE="${1:-}"
      ;;
    --emoji-offset-x)
      shift; EMOJI_OFFSET_X="${1:-}"
      ;;
    --emoji-offset-y)
      shift; EMOJI_OFFSET_Y="${1:-}"
      ;;

    # Timing options
    --frame-delay)
      shift; FRAME_DELAY_START="${1:-}"
      ;;
    --fps)
      shift; FPS="${1:-}"
      ;;
    --duration)
      shift; DURATION_FALLBACK="${1:-}"
      ;;

    # Help
    --help)
      usage
      exit 0
      ;;

    # Unknown option or positional arg
    --*)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      # End of options, start of positional args
      break
      ;;
  esac
  shift
done

# ============================================================================
# POSITIONAL ARGUMENTS
# ============================================================================

if [ $# -ne 2 ]; then
  echo "ERR: expected INPUT and OUT positional args." >&2
  usage
  exit 1
fi

INPUT_ARG="$1"
OUT_ARG="$2"

# ============================================================================
# PATH RESOLUTION
# ============================================================================

# Normalize base directories (remove trailing slash)
trim_trail() { printf '%s' "${1%/}"; }
ASSETS_DIR="$(trim_trail "$ASSETS_DIR")"
INPUT_BASE="$(trim_trail "$INPUT_BASE")"
[ -n "$OUTPUT_DIR" ] && OUTPUT_DIR="$(trim_trail "$OUTPUT_DIR")"

# --- Safe resolution of INPUT_ARG -> INPUT_FILE (portable) ---
if [[ "$INPUT_ARG" = /* ]]; then
  # absolute path: use as-is
  INPUT_FILE="$INPUT_ARG"
elif [[ "$INPUT_ARG" == *"://"* ]]; then
  # looks like a URL: strip scheme and host -> path after host
  # e.g. https://host/some/path/file.mp4 -> some/path/file.mp4
  tmp="${INPUT_ARG#*://}"       # remove scheme://
  REL_PATH="${tmp#*/}"         # remove up-to-first-slash (the host) and keep path after it
  INPUT_FILE="${INPUT_BASE}/${REL_PATH}"
else
  # treat as relative path (trim any leading ./ or /)
  REL_PATH="${INPUT_ARG#./}"
  REL_PATH="${REL_PATH#/}"
  INPUT_FILE="${INPUT_BASE}/${REL_PATH}"
fi

# Resolve OUT_VIDEO:
if [[ "$OUT_ARG" == *"/"* ]]; then
  OUT_VIDEO="$OUT_ARG"
else
  if [ -n "$OUTPUT_DIR" ]; then
    OUT_VIDEO="${OUTPUT_DIR}/${OUT_ARG}"
  else
    OUT_VIDEO="${ASSETS_DIR}/${OUT_ARG}"
  fi
fi

# ============================================================================
# DERIVED PATHS AND SETUP
# ============================================================================

# Create necessary directories
mkdir -p "$ASSETS_DIR" "$ASSETS_DIR/fonts" "$ASSETS_DIR/icons" "$OUTPUT_DIR" "$INPUT_BASE" "${SCRIPT_DIR}/temp"

# Font path (check both assets root and assets/fonts)
if [ -f "${ASSETS_DIR}/fonts/${FONT_FILE}" ]; then
  FONT="${ASSETS_DIR}/fonts/${FONT_FILE}"
elif [ -f "${ASSETS_DIR}/${FONT_FILE}" ]; then
  FONT="${ASSETS_DIR}/${FONT_FILE}"
else
  FONT="${ASSETS_DIR}/fonts/${FONT_FILE}"
fi

# Icon paths
EYE_ICON="${ASSETS_DIR}/icons/eye.png"
[ ! -f "$EYE_ICON" ] && EYE_ICON="${ASSETS_DIR}/eye.png"

EMOJI_PNG="${ASSETS_DIR}/icons/emoji.png"
[ ! -f "$EMOJI_PNG" ] && EMOJI_PNG="${ASSETS_DIR}/emoji.png"

# Temp file paths (stored in temp directory)
TEMP_DIR="${SCRIPT_DIR}/temp"
SCREENSHOT_PNG="${TEMP_DIR}/frame_with_views.png"
TMP_FRAME="${TEMP_DIR}/_tmp_frame.png"
CAPTION_PNG="${TEMP_DIR}/caption_canvas.png"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# helper: convert percent like "5%" to px given dim; otherwise return integer value
pct_to_px() {
  val="$1"
  dim="$2"
  if printf '%s' "$val" | grep -qE '^[0-9]+%$'; then
    p=${val%\%}
    echo $(( (p * dim) / 100 ))
  else
    if [ -z "$val" ]; then
      echo 0
    else
      echo "$val"
    fi
  fi
}

# Generate random view count (cross-platform compatible)
if command -v shuf >/dev/null 2>&1; then
  VIEWS="$(shuf -i${RAND_MIN}-${RAND_MAX} -n1)M"
else
  # macOS fallback using jot
  VIEWS="$(jot -r 1 ${RAND_MIN} ${RAND_MAX})M"
fi

# ============================================================================
# LOGGING AND VALIDATION
# ============================================================================

echo "============================================" >&2
echo "Video Overlay Processing" >&2
echo "============================================" >&2
echo "INPUT_ARG: $INPUT_ARG" >&2
echo "INPUT_FILE: $INPUT_FILE" >&2
echo "ASSETS_DIR: $ASSETS_DIR" >&2
echo "INPUT_BASE: $INPUT_BASE" >&2
echo "OUT_VIDEO: $OUT_VIDEO" >&2
echo "VIEWS: $VIEWS" >&2
echo "CAPTION: $CAPTION_TEXT" >&2
echo "PLACEMENT: $PLACEMENT" >&2
echo "============================================" >&2

# sanity check input exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "ERR: input not found: $INPUT_FILE" >&2
  exit 1
fi

# ensure output parent dir exists (if OUT_VIDEO is a path)
OUT_PARENT="$(dirname -- "$OUT_VIDEO")"
if [ ! -d "$OUT_PARENT" ]; then
  mkdir -p "$OUT_PARENT"
fi

# ensure eye icon exists (transparent fallback)
if [ ! -f "$EYE_ICON" ]; then
  echo "Note: eye icon missing at $EYE_ICON — creating transparent placeholder" >&2
  ffmpeg -f lavfi -i "color=rgba(0,0,0,0):s=${ICON_SIZE}x${ICON_SIZE}:d=1" -frames:v 1 -y "$EYE_ICON" >/dev/null 2>&1 || true
fi

# ============================================================================
# STEP 1: EXTRACT FRAME
# ============================================================================

echo "1/4: Extracting frame at 2s -> $TMP_FRAME" >&2
ffmpeg -ss 2 -i "$INPUT_FILE" -frames:v 1 -q:v 2 -y "$TMP_FRAME" 2>&1 | grep -v "^frame=" || true

# compute video/frame dimensions
VID_H=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$INPUT_FILE" 2>/dev/null || echo 1080)
VID_W=$(ffprobe -v error -select_streams v:0 -show_entries stream=width  -of csv=p=0 "$INPUT_FILE" 2>/dev/null || echo 1080)
VID_H=${VID_H:-1080}
VID_W=${VID_W:-1080}

FRAME_H=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$TMP_FRAME" 2>/dev/null || echo "$VID_H")
FRAME_W=$(ffprobe -v error -select_streams v:0 -show_entries stream=width  -of csv=p=0 "$TMP_FRAME" 2>/dev/null || echo "$VID_W")
FRAME_H=${FRAME_H:-$VID_H}
FRAME_W=${FRAME_W:-$VID_W}

OFS_X_PX=$(pct_to_px "${ICON_OFFSET_X}" "$FRAME_W")
OFS_Y_PX=$(pct_to_px "${ICON_OFFSET_Y}" "$FRAME_H")

case "$ICON_ANCHOR" in
  bottom-left)
    ICON_X=$OFS_X_PX
    ICON_Y=$(( FRAME_H - OFS_Y_PX - ICON_SIZE ))
    ;;
  bottom-right)
    ICON_X=$(( FRAME_W - OFS_X_PX - ICON_SIZE ))
    ICON_Y=$(( FRAME_H - OFS_Y_PX - ICON_SIZE ))
    ;;
  top-left)
    ICON_X=$OFS_X_PX
    ICON_Y=$OFS_Y_PX
    ;;
  top-right)
    ICON_X=$(( FRAME_W - OFS_X_PX - ICON_SIZE ))
    ICON_Y=$OFS_Y_PX
    ;;
  *)
    ICON_X=$OFS_X_PX
    ICON_Y=$(( FRAME_H - OFS_Y_PX - ICON_SIZE ))
    ;;
esac

[ "$ICON_X" -lt 0 ] && ICON_X=0
[ "$ICON_Y" -lt 0 ] && ICON_Y=0
[ "$ICON_X" -gt $((FRAME_W - ICON_SIZE)) ] && ICON_X=$((FRAME_W - ICON_SIZE))
[ "$ICON_Y" -gt $((FRAME_H - ICON_SIZE)) ] && ICON_Y=$((FRAME_H - ICON_SIZE))

TEXT_X=$(( ICON_X + ICON_SIZE + TEXT_GAP + TEXT_OFFSET_X ))
TEXT_Y=$(( ICON_Y + ICON_SIZE/2 - FONTSIZE/2 + TEXT_OFFSET_Y ))
if [ "$TEXT_Y" -lt 0 ]; then TEXT_Y=0; fi

echo "Computed screenshot ICON at (${ICON_X},${ICON_Y}), TEXT at (${TEXT_X},${TEXT_Y}), FRAME=${FRAME_W}x${FRAME_H}, VIDEO=${VID_W}x${VID_H}" >&2

# ============================================================================
# STEP 2: CREATE SCREENSHOT IMAGE (ICON + VIEWS)
# ============================================================================

echo "2/4: Creating screenshot image (Pillow)" >&2
export TMP_FRAME SCREENSHOT_PNG EYE_ICON VIEWS FONT ICON_X ICON_Y ICON_SIZE TEXT_X TEXT_Y FONTSIZE

python3 - <<'PY'
import os, sys
from PIL import Image, ImageDraw, ImageFont

tmp_frame = os.environ["TMP_FRAME"]
out_png = os.environ["SCREENSHOT_PNG"]
eye_icon = os.environ["EYE_ICON"]
v = os.environ["VIEWS"]
ICON_X = int(os.environ.get("ICON_X", "24"))
ICON_Y = int(os.environ.get("ICON_Y", "64"))
ICON_SIZE = int(os.environ.get("ICON_SIZE", "64"))
TEXT_X = int(os.environ.get("TEXT_X", str(ICON_X + ICON_SIZE + 5)))
TEXT_Y = int(os.environ.get("TEXT_Y", str(ICON_Y)))
FONTSIZE = int(os.environ.get("FONTSIZE", "48"))
fontpath = os.environ.get("FONT", "")

bg = Image.open(tmp_frame).convert("RGBA")

try:
    icon = Image.open(eye_icon).convert("RGBA").resize((ICON_SIZE, ICON_SIZE))
    bg.paste(icon, (ICON_X, ICON_Y), icon)
except Exception as e:
    sys.stderr.write(f"Warning: Could not load eye icon: {e}\n")

# Get script directory for font search
script_dir = os.path.dirname(os.path.abspath(os.environ.get("FONT", "")))
assets_dir = os.path.dirname(script_dir) if script_dir else ""

candidates = [
    fontpath,
    os.path.join(assets_dir, "fonts", "ARIALBD 1.TTF"),
    os.path.join(assets_dir, "fonts", "Arial.ttf"),
    os.path.join(assets_dir, "fonts", "DejaVuSans-Bold.ttf"),
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    "/Library/Fonts/Arial.ttf",
    "/System/Library/Fonts/Supplemental/Arial.ttf"
]
font = None
for p in candidates:
    if p and os.path.isfile(p):
        try:
            font = ImageFont.truetype(p, FONTSIZE)
            break
        except Exception:
            font = None
if font is None:
    font = ImageFont.load_default()

draw = ImageDraw.Draw(bg)
draw.text((TEXT_X, TEXT_Y), v, font=font, fill=(255,255,255,255))

bg.save(out_png)
sys.stderr.write(f"Created: {out_png}\n")
PY

chmod 644 "$SCREENSHOT_PNG"

if [ ! -f "$SCREENSHOT_PNG" ]; then
  echo "ERR: screenshot image not created: $SCREENSHOT_PNG" >&2
  exit 1
fi

# ============================================================================
# STEP 3: CREATE CAPTION BAR
# ============================================================================

echo "3/4: Building caption PNG -> $CAPTION_PNG" >&2
# Replace [VIEWS] placeholder in caption text
CAPTION_FINAL="${CAPTION_TEXT//\[VIEWS\]/$VIEWS}"
export CAPTION_PNG VID_W BAR_HEIGHT CAPTION_FONT_SIZE BAR_BG_OPACITY CAPTION_FINAL FONT

python3 - <<'PY'
import os, sys
from PIL import Image, ImageDraw, ImageFont

out = os.environ["CAPTION_PNG"]
vidw = int(os.environ.get("VID_W", "1080"))
barh = int(os.environ.get("BAR_HEIGHT", "110"))
txt = " " + os.environ.get("CAPTION_FINAL", "")
fontsize = int(os.environ.get("CAPTION_FONT_SIZE", "64"))
bar_opacity = int(os.environ.get("BAR_BG_OPACITY", "80"))
fontpath = os.environ.get("FONT", "")

# Get script directory for font search
script_dir = os.path.dirname(os.path.abspath(fontpath)) if fontpath else ""
assets_dir = os.path.dirname(script_dir) if script_dir else ""

candidates = [
    fontpath,
    os.path.join(assets_dir, "fonts", "ARIALBD 1.TTF"),
    os.path.join(assets_dir, "fonts", "Arial.ttf"),
    os.path.join(assets_dir, "fonts", "DejaVuSans-Bold.ttf"),
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    "/Library/Fonts/Arial.ttf",
    "/System/Library/Fonts/Supplemental/Arial.ttf"
]
font = None
for p in candidates:
    if p and os.path.isfile(p):
        try:
            font = ImageFont.truetype(p, fontsize)
            break
        except Exception:
            font = None
if font is None:
    font = ImageFont.load_default()
    fontsize = 16

tmp = Image.new("RGBA", (10,10), (0,0,0,0))
draw = ImageDraw.Draw(tmp)
try:
    bbox = draw.textbbox((0,0), txt, font=font)
    w = bbox[2]-bbox[0]; h = bbox[3]-bbox[1]
except Exception:
    w,h = draw.textsize(txt, font=font)

img = Image.new("RGBA", (vidw, barh), (0,0,0,0))
d = ImageDraw.Draw(img)
d.rectangle([(0,0),(vidw,barh)], fill=(0,0,0,bar_opacity))

tx = (vidw - w) // 2
ty = (barh - h) // 2
d.text((tx,ty), txt, font=font, fill=(255,255,255,255))

img.save(out)
sys.stderr.write(f"Created: {out}\n")
PY

chmod 644 "$CAPTION_PNG"

# ============================================================================
# STEP 4: COMPOSE FINAL VIDEO
# ============================================================================

echo "4/4: Composing final video -> $OUT_VIDEO" >&2
echo "Enabled overlays: Screenshot=$ENABLE_SCREENSHOT, Caption=$ENABLE_CAPTION, Emoji=$ENABLE_EMOJI" >&2

# Compute overlay pixel sizes (OVERLAY_W / OVERLAY_H may be percent)
OVERLAY_W_PX=$(pct_to_px "${OVERLAY_W}" "$VID_W")
OVERLAY_H_PX=$(pct_to_px "${OVERLAY_H}" "$VID_H")

if [ "$OVERLAY_W_PX" -le 0 ] || [ "$OVERLAY_W_PX" -gt "$VID_W" ]; then
  OVERLAY_W_PX=$(( VID_W / 5 ))
fi
if [ "$OVERLAY_H_PX" -le 0 ] || [ "$OVERLAY_H_PX" -gt "$VID_H" ]; then
  OVERLAY_H_PX=$(( VID_H / 3 ))
fi

echo "Overlay final size = ${OVERLAY_W_PX}px x ${OVERLAY_H_PX}px (computed from ${OVERLAY_W} x ${OVERLAY_H})" >&2

case "$PLACEMENT" in
  top-right)
    OV_X_EXPR="W-w-${OVERLAY_OFFSET_X}"
    OV_Y_EXPR="${OVERLAY_OFFSET_Y}"
    ;;
  top-left)
    OV_X_EXPR="${OVERLAY_OFFSET_X}"
    OV_Y_EXPR="${OVERLAY_OFFSET_Y}"
    ;;
  bottom-right)
    OV_X_EXPR="W-w-${OVERLAY_OFFSET_X}"
    OV_Y_EXPR="H-h-${OVERLAY_OFFSET_Y}"
    ;;
  bottom-left)
    OV_X_EXPR="${OVERLAY_OFFSET_X}"
    OV_Y_EXPR="H-h-${OVERLAY_OFFSET_Y}"
    ;;
  *)
    OV_X_EXPR="W-w-${OVERLAY_OFFSET_X}"
    OV_Y_EXPR="${OVERLAY_OFFSET_Y}"
    ;;
esac

# Build ffmpeg command dynamically based on enabled overlays
FFMPEG_INPUTS="-i \"$INPUT_FILE\""
FILTER_COMPLEX=""
CURRENT_STREAM="0:v"
INPUT_INDEX=1

# Add screenshot overlay if enabled
if [ "$ENABLE_SCREENSHOT" = "true" ]; then
  FFMPEG_INPUTS="$FFMPEG_INPUTS -i \"$SCREENSHOT_PNG\""
  FILTER_COMPLEX="[${INPUT_INDEX}:v]scale=${OVERLAY_W_PX}:${OVERLAY_H_PX}[ov]; "
  FILTER_COMPLEX="${FILTER_COMPLEX}[${CURRENT_STREAM}][ov]overlay=x=${OV_X_EXPR}:y=${OV_Y_EXPR}:enable='gte(t,${FRAME_DELAY_START})'[step${INPUT_INDEX}]; "
  CURRENT_STREAM="step${INPUT_INDEX}"
  INPUT_INDEX=$((INPUT_INDEX + 1))
  echo "Adding screenshot overlay" >&2
fi

# Add caption overlay if enabled
if [ "$ENABLE_CAPTION" = "true" ]; then
  FFMPEG_INPUTS="$FFMPEG_INPUTS -i \"$CAPTION_PNG\""
  FILTER_COMPLEX="${FILTER_COMPLEX}[${CURRENT_STREAM}][${INPUT_INDEX}:v]overlay=x=(main_w-overlay_w)/2:y=${BAR_OFFSET_Y}[step${INPUT_INDEX}]; "
  CURRENT_STREAM="step${INPUT_INDEX}"
  INPUT_INDEX=$((INPUT_INDEX + 1))
  echo "Adding caption overlay" >&2
fi

# Add emoji overlay if enabled and file exists
if [ "$ENABLE_EMOJI" = "true" ] && [ -f "${EMOJI_PNG}" ]; then
  FFMPEG_INPUTS="$FFMPEG_INPUTS -i \"${EMOJI_PNG}\""
  FILTER_COMPLEX="${FILTER_COMPLEX}[${INPUT_INDEX}:v]scale=${EMOJI_SIZE}:${EMOJI_SIZE}[emoji]; "
  FILTER_COMPLEX="${FILTER_COMPLEX}[${CURRENT_STREAM}][emoji]overlay=x=${EMOJI_OFFSET_X}:y=${EMOJI_OFFSET_Y}[step${INPUT_INDEX}]; "
  CURRENT_STREAM="step${INPUT_INDEX}"
  INPUT_INDEX=$((INPUT_INDEX + 1))
  echo "Adding emoji overlay" >&2
elif [ "$ENABLE_EMOJI" = "true" ]; then
  echo "Emoji overlay requested but ${EMOJI_PNG} not found, skipping" >&2
fi

# Remove trailing semicolon and space from filter
FILTER_COMPLEX="${FILTER_COMPLEX%; }"

# If no overlays enabled, just re-encode
if [ -z "$FILTER_COMPLEX" ]; then
  echo "No overlays enabled, creating copy of input video" >&2
  eval "ffmpeg -y -i \"$INPUT_FILE\" -t \"${DURATION_FALLBACK}\" -r ${FPS} -c:v libx264 -preset veryfast -c:a copy \"$OUT_VIDEO\" 2>&1 | grep -v \"^frame=\" || true"
else
  # Build and execute ffmpeg command with overlays
  eval "ffmpeg -y $FFMPEG_INPUTS -t \"${DURATION_FALLBACK}\" -filter_complex \"$FILTER_COMPLEX\" -map \"[${CURRENT_STREAM}]\" -map 0:a? -r ${FPS} -c:v libx264 -preset veryfast -c:a copy \"$OUT_VIDEO\" 2>&1 | grep -v \"^frame=\" || true"
fi

if [ $? -eq 0 ] && [ -f "$OUT_VIDEO" ]; then
  # Clean up temporary files
  rm -f "$TMP_FRAME" "$SCREENSHOT_PNG" "$CAPTION_PNG" 2>/dev/null

  # Print complete output file path
  echo "$OUT_VIDEO"
  exit 0
else
  echo "ERR: final ffmpeg compose failed" >&2
  echo "Temporary files kept in $TEMP_DIR for debugging" >&2
  exit 1
fi
