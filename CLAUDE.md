# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains `views.sh`, a Bash script that processes video files by overlaying:
1. A screenshot thumbnail with view count (top-right corner by default)
2. A caption bar with call-to-action text (centered bottom)
3. An optional emoji overlay

The script uses **ffmpeg** for video processing and **Python 3 with PIL (Pillow)** for image composition.

## Script Architecture

The script follows a 4-stage pipeline:

1. **Input Resolution** (lines 80-95): Normalizes INPUT_ARG (relative path, URL, or absolute path) to an absolute file path
2. **Frame Extraction** (lines 196-199): Extracts a single frame at 2 seconds using ffmpeg
3. **Image Composition** (lines 249-367): Uses Python PIL to create:
   - `frame_with_views.png`: Screenshot with eye icon + view count
   - `caption_canvas.png`: Semi-transparent bar with caption text
4. **Video Composition** (lines 382-426): Overlays all elements onto the video using ffmpeg filter_complex

## Key Configuration Variables

All customization happens via environment variables (lines 111-140):

**View Count Overlay:**
- `PLACEMENT`: Position of screenshot overlay (top-right, top-left, bottom-right, bottom-left)
- `ICON_ANCHOR`: Position of eye icon within screenshot (bottom-left, bottom-right, top-left, top-right)
- `ICON_SIZE`: Eye icon size in pixels (default: 64)
- `ICON_OFFSET_X/Y`: Distance from anchor point (accepts px or %, e.g., "4%")
- `FONTSIZE`: View count text size (default: 48)
- `RAND_MIN/MAX`: View count range in millions (default: 1-100M)

**Screenshot Overlay:**
- `OVERLAY_W/H`: Thumbnail dimensions (accepts px or %, default: 30%, 25%)
- `OVERLAY_OFFSET_X/Y`: Distance from corner (default: 20px, 110px)

**Caption Bar:**
- `BAR_HEIGHT`: Caption bar height in pixels (default: 110)
- `BAR_BG_OPACITY`: Background opacity 0-255 (default: 229)
- `CAPTION_FONT_SIZE`: Text size (default: 40)
- Caption text is hardcoded at line 322: `" [VIEWS] Apko Bhi Sikhna Hai To Comment Kro"`

**Emoji Overlay:**
- `EMOJI_SIZE`: Emoji dimensions (default: 74)
- `EMOJI_OFFSET_X/Y`: Position from top-left (default: 50px, 20px)

**Timing:**
- `FRAME_DELAY_START`: Delay before showing screenshot (default: 0s)
- `FPS`: Output frame rate (default: 30)
- `DURATION_FALLBACK`: Max output duration (default: 600s)

## Running the Script

### Basic Usage
```bash
./views.sh INPUT OUT
```

### With Custom Directories
```bash
./views.sh --assets-dir /custom/assets --input-base /custom/inputs --output-dir /custom/outputs INPUT OUT
```

### Examples
```bash
# Relative path input
./views.sh "KnowSparkz/video.mp4" output.mp4

# URL input (strips host and resolves to input-base)
./views.sh "https://example.com/videos/input.mp4" result.mp4

# Absolute path
./views.sh "/full/path/to/video.mp4" "/full/path/to/output.mp4"

# Custom view count range (1-50M)
RAND_MIN=1 RAND_MAX=50 ./views.sh input.mp4 output.mp4

# Bottom-left screenshot placement
PLACEMENT=bottom-left ./views.sh input.mp4 output.mp4
```

## Required Assets

Place these files in `--assets-dir` (default: `/files/extra`):

1. **ARIALBD 1.TTF**: Font file for text rendering (or modify `FONT_FILE` at line 109)
2. **eye.png**: Eye icon for view count (transparent PNG, auto-created if missing)
3. **emoji.png**: Optional emoji overlay (if missing, emoji overlay is skipped)

## Dependencies

- **ffmpeg**: Video processing and frame extraction
- **ffprobe**: Video metadata extraction (comes with ffmpeg)
- **python3**: Image composition
- **PIL/Pillow**: Python imaging library (`pip install Pillow`)

## Modifying Caption Text

To change the caption message, edit line 322 in the Python heredoc:
```python
txt = f" [{os.environ.get('VIEWS','0M')}] Your Custom Message Here"
```

## Output Behavior

- The script prints the **basename** of the output file to stdout (line 430)
- All logs and progress messages go to stderr
- Exit code 0 indicates success; non-zero indicates failure

## Font Fallback Logic

Both Python sections (lines 277-293, 327-341) attempt fonts in this order:
1. `$FONT` (from FONT_FILE variable)
2. `/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf` (Linux)
3. `/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf` (Linux)
4. `/Library/Fonts/Arial.ttf` (macOS)
5. `/System/Library/Fonts/Supplemental/Arial.ttf` (macOS)
6. Default PIL font (last resort)

## Percentage-to-Pixel Conversion

The `pct_to_px()` helper (lines 153-166) converts strings like "5%" to pixels based on video dimensions. Used for offsets and overlay sizes.
