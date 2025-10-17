# Video Overlay Processor

A powerful Bash script that automatically adds professional-looking overlays to videos including view counts, captions, and emoji graphics. Perfect for creating engaging social media content!

## Features

- **Screenshot Overlay**: Adds a thumbnail preview with view count to any corner of the video
- **Caption Bar**: Customizable text overlay with semi-transparent background
- **Emoji Overlay**: Optional emoji/icon overlay
- **Random View Counts**: Generates random view counts (e.g., "42M views")
- **Highly Configurable**: All aspects can be customized via command-line arguments
- **Flexible Input**: Supports local paths, URLs, and relative paths
- **Professional Output**: Uses ffmpeg for high-quality video processing

## Demo

The script transforms your video by adding:
1. A screenshot thumbnail (default: top-right corner) showing a preview with eye icon + view count
2. A caption bar (default: bottom) with customizable call-to-action text
3. Optional emoji overlay for extra engagement

## Prerequisites

### Required Software

- **ffmpeg** (with libx264 support)
- **ffprobe** (comes with ffmpeg)
- **python3**
- **PIL/Pillow** (Python imaging library)

### Installation

#### macOS
```bash
# Install ffmpeg
brew install ffmpeg

# Install Python and Pillow
brew install python3
pip3 install Pillow
```

#### Ubuntu/Debian
```bash
# Install ffmpeg
sudo apt update
sudo apt install ffmpeg

# Install Python and Pillow
sudo apt install python3 python3-pip
pip3 install Pillow
```

#### Windows (WSL or Git Bash)
```bash
# Install ffmpeg (download from ffmpeg.org or use chocolatey)
choco install ffmpeg

# Install Python and Pillow
python -m pip install Pillow
```

### Required Assets

Place these files in your assets directory (default: `/files/extra`):

1. **Font file**: `ARIALBD 1.TTF` (or any TTF font)
   - Download Arial Bold or use any custom font
   - Update `--font-file` parameter if using different font

2. **Eye icon**: `eye.png` (optional)
   - Transparent PNG recommended
   - Default size: 64x64px
   - Auto-generated if missing (transparent placeholder)

3. **Emoji**: `emoji.png` (optional)
   - Only used if present in assets directory
   - Recommended size: 74x74px or larger

## Quick Start

### Basic Usage

```bash
# Make script executable
chmod +x views.sh

# Process a video with default settings
./views.sh input.mp4 output.mp4
```

### Simple Examples

```bash
# Custom view count range (10M-50M views)
./views.sh --rand-min 10 --rand-max 50 input.mp4 output.mp4

# Custom caption text
./views.sh --caption-text "[VIEWS] Subscribe for More!" input.mp4 output.mp4

# Move screenshot to bottom-left
./views.sh --placement bottom-left input.mp4 output.mp4

# Make screenshot bigger (50% width, 40% height)
./views.sh --overlay-width 50% --overlay-height 40% input.mp4 output.mp4

# Only caption overlay (no screenshot, no emoji)
./views.sh --no-screenshot --no-emoji input.mp4 output.mp4

# Only screenshot overlay (no caption, no emoji)
./views.sh --no-caption --no-emoji input.mp4 output.mp4

# No overlays at all (just re-encode)
./views.sh --no-screenshot --no-caption --no-emoji input.mp4 output.mp4
```

## Complete Usage Guide

### Syntax

```bash
./views.sh [OPTIONS] INPUT OUTPUT
```

### Positional Arguments

- **INPUT**: Input video file (supports 3 formats):
  - Relative path: `videos/input.mp4` (resolved to `INPUT_BASE/videos/input.mp4`)
  - Full URL: `https://example.com/videos/input.mp4` (downloads to `INPUT_BASE/videos/input.mp4`)
  - Absolute path: `/full/path/to/input.mp4` (used as-is)

- **OUTPUT**: Output video file:
  - With path: `/custom/path/output.mp4` (used as-is)
  - Basename only: `output.mp4` (written to `OUTPUT_DIR` or `ASSETS_DIR`)

### All Available Options

#### Toggle Options (Enable/Disable Overlays)

| Option | Description | Effect |
|--------|-------------|--------|
| `--no-screenshot` | Disable screenshot overlay | Removes view count thumbnail |
| `--no-caption` | Disable caption bar overlay | Removes bottom caption text |
| `--no-emoji` | Disable emoji overlay | Removes emoji graphic |
| `--overlay-only` | Caption + emoji only (no screenshot) | Same as `--no-screenshot` |

**Examples:**
```bash
# Only caption overlay
./views.sh --no-screenshot --no-emoji input.mp4 output.mp4

# Only screenshot overlay
./views.sh --no-caption --no-emoji input.mp4 output.mp4

# No overlays (just re-encode)
./views.sh --no-screenshot --no-caption --no-emoji input.mp4 output.mp4
```

#### Directory Options

| Option | Description | Default |
|--------|-------------|---------|
| `--assets-dir DIR` | Assets folder (font, icons, temp files) | `./assets` |
| `--input-base DIR` | Base folder for relative inputs | `./input` |
| `--output-dir DIR` | Output folder when OUT is basename | `./output` |

#### View Count Overlay Options

| Option | Description | Default |
|--------|-------------|---------|
| `--placement POS` | Screenshot position<br>(`top-right`, `top-left`, `bottom-right`, `bottom-left`) | `top-right` |
| `--icon-anchor POS` | Eye icon anchor point<br>(`top-right`, `top-left`, `bottom-right`, `bottom-left`) | `bottom-left` |
| `--icon-size SIZE` | Eye icon size in pixels | `64` |
| `--icon-offset-x OFFSET` | Icon X offset (pixels or `%`) | `4%` |
| `--icon-offset-y OFFSET` | Icon Y offset (pixels or `%`) | `4%` |
| `--text-gap GAP` | Gap between icon and text (px) | `6` |
| `--font-size SIZE` | View count font size (px) | `48` |
| `--text-offset-x OFFSET` | Text X adjustment (px) | `0` |
| `--text-offset-y OFFSET` | Text Y adjustment (px) | `0` |
| `--rand-min MIN` | Min view count (millions) | `1` |
| `--rand-max MAX` | Max view count (millions) | `100` |

#### Screenshot Overlay Options

| Option | Description | Default |
|--------|-------------|---------|
| `--overlay-width WIDTH` | Screenshot width (pixels or `%`) | `30%` |
| `--overlay-height HEIGHT` | Screenshot height (pixels or `%`) | `25%` |
| `--overlay-offset-x OFF` | Screenshot X offset (px) | `20` |
| `--overlay-offset-y OFF` | Screenshot Y offset (px) | `110` |

#### Caption Bar Options

| Option | Description | Default |
|--------|-------------|---------|
| `--caption-text TEXT` | Caption text (`[VIEWS]` = placeholder) | `[VIEWS] Apko Bhi Sikhna Hai To Comment Kro` |
| `--bar-height HEIGHT` | Caption bar height (px) | `110` |
| `--bar-offset-y OFFSET` | Caption bar Y offset (px) | `0` |
| `--bar-opacity OPACITY` | Bar background opacity (0-255) | `229` |
| `--caption-font-size SIZE` | Caption font size (px) | `40` |

#### Emoji Overlay Options

| Option | Description | Default |
|--------|-------------|---------|
| `--emoji-size SIZE` | Emoji size (px) | `74` |
| `--emoji-offset-x OFF` | Emoji X offset from top-left (px) | `50` |
| `--emoji-offset-y OFF` | Emoji Y offset from top-left (px) | `20` |

#### Timing Options

| Option | Description | Default |
|--------|-------------|---------|
| `--frame-delay SECONDS` | Delay before showing screenshot | `0` |
| `--fps FPS` | Output video frame rate | `30` |
| `--duration SECONDS` | Max output duration | `600` |

#### Other Options

| Option | Description | Default |
|--------|-------------|---------|
| `--font-file FILENAME` | Font filename (in assets-dir) | `ARIALBD 1.TTF` |
| `--help` | Show help message | - |

## Advanced Examples

### Example 1: YouTube-Style Overlay

```bash
./views.sh \
  --caption-text "[VIEWS] Don't Forget to Like & Subscribe!" \
  --placement top-right \
  --overlay-width 35% \
  --overlay-height 28% \
  --rand-min 100 \
  --rand-max 500 \
  input.mp4 youtube_style.mp4
```

### Example 2: Instagram-Style Overlay

```bash
./views.sh \
  --caption-text "[VIEWS] ❤️ Double tap if you agree!" \
  --placement bottom-right \
  --overlay-width 25% \
  --overlay-height 20% \
  --bar-height 90 \
  --caption-font-size 32 \
  --rand-min 5 \
  --rand-max 50 \
  input.mp4 instagram_style.mp4
```

### Example 3: Custom Assets Directory

```bash
./views.sh \
  --assets-dir ./my-assets \
  --font-file "MyCustomFont.ttf" \
  --caption-text "[VIEWS] Learn More in Description!" \
  input.mp4 output.mp4
```

### Example 4: Delayed Screenshot Overlay

```bash
./views.sh \
  --frame-delay 3 \
  --caption-text "[VIEWS] Watch till the end!" \
  --rand-min 10 \
  --rand-max 25 \
  input.mp4 delayed_overlay.mp4
```

### Example 5: Minimal View Count (Education Content)

```bash
./views.sh \
  --rand-min 1 \
  --rand-max 5 \
  --caption-text "[VIEWS] Tutorial - Part 1" \
  --placement bottom-left \
  --overlay-width 20% \
  --overlay-height 15% \
  input.mp4 tutorial.mp4
```

### Example 6: Viral Video Style

```bash
./views.sh \
  --rand-min 500 \
  --rand-max 1000 \
  --caption-text "[VIEWS] This Changed Everything!" \
  --bar-opacity 200 \
  --bar-height 130 \
  --caption-font-size 52 \
  --font-size 56 \
  input.mp4 viral_style.mp4
```

### Example 7: Custom Positioning

```bash
./views.sh \
  --placement top-left \
  --icon-anchor top-right \
  --overlay-offset-x 40 \
  --overlay-offset-y 40 \
  --icon-offset-x 30 \
  --icon-offset-y 30 \
  input.mp4 custom_position.mp4
```

## Batch Processing

Process multiple videos at once:

```bash
#!/bin/bash
# batch_process.sh

for video in videos/*.mp4; do
  filename=$(basename "$video" .mp4)
  ./views.sh \
    --caption-text "[VIEWS] Amazing Content!" \
    --rand-min 10 \
    --rand-max 100 \
    "$video" \
    "output/${filename}_processed.mp4"
done
```

## Tips & Best Practices

### 1. Caption Text Placeholder

Use `[VIEWS]` in your caption text to insert the generated view count:

```bash
# Good: View count will replace [VIEWS]
--caption-text "[VIEWS] Subscribe for more!"
# Result: "42M Subscribe for more!"

# Also works: Multiple placeholders
--caption-text "🔥 [VIEWS] views! [VIEWS] people can't be wrong!"
# Result: "🔥 42M views! 42M people can't be wrong!"
```

### 2. Percentage vs Pixel Values

Use percentages for responsive sizing:

```bash
# Responsive (recommended)
--overlay-width 30% --overlay-height 25%
--icon-offset-x 5% --icon-offset-y 5%

# Fixed pixels
--overlay-width 400 --overlay-height 300
--icon-offset-x 50 --icon-offset-y 50
```

### 3. Optimal View Count Ranges

```bash
# Educational/Tutorial: 1-10M
--rand-min 1 --rand-max 10

# Entertainment: 10-100M
--rand-min 10 --rand-max 100

# Viral/Trending: 100-1000M
--rand-min 100 --rand-max 1000
```

### 4. Caption Bar Opacity

Opacity ranges from 0 (fully transparent) to 255 (fully opaque):

```bash
# Subtle (more transparent)
--bar-opacity 150

# Standard (default)
--bar-opacity 229

# Bold (nearly opaque)
--bar-opacity 240
```

### 5. Font Fallback

The script automatically tries multiple fonts:
1. Your specified font (via `--font-file`)
2. DejaVu Sans Bold (Linux)
3. Liberation Sans Bold (Linux)
4. Arial (macOS)
5. System Arial (macOS fallback)
6. Default PIL font (last resort)

## Troubleshooting

### Error: "input not found"

**Problem**: The script can't find your input video.

**Solution**:
```bash
# Use absolute path
./views.sh /full/path/to/video.mp4 output.mp4

# Or check your input-base directory
./views.sh --input-base /path/to/videos input.mp4 output.mp4
```

### Error: "ffmpeg: command not found"

**Problem**: ffmpeg is not installed.

**Solution**:
```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt install ffmpeg
```

### Error: "No module named 'PIL'"

**Problem**: Pillow library is not installed.

**Solution**:
```bash
pip3 install Pillow
# or
python3 -m pip install Pillow
```

### Warning: "eye icon missing"

**Problem**: `eye.png` not found in assets directory.

**Solution**: The script auto-generates a transparent placeholder, or you can add your own:
```bash
# Copy your eye icon
cp /path/to/eye.png /files/extra/eye.png

# Or use custom assets directory
./views.sh --assets-dir ./my-assets input.mp4 output.mp4
```

### Output Video is Too Long/Short

**Problem**: Output duration doesn't match input.

**Solution**: Adjust the duration parameter:
```bash
# Set max duration to 300 seconds (5 minutes)
./views.sh --duration 300 input.mp4 output.mp4
```

### Text is Cut Off or Positioned Incorrectly

**Problem**: View count text extends beyond frame.

**Solution**: Adjust text offsets or use smaller font:
```bash
./views.sh \
  --font-size 40 \
  --text-offset-x -10 \
  --text-offset-y 5 \
  input.mp4 output.mp4
```

## How It Works

The script follows a 4-stage pipeline:

1. **Frame Extraction**: Extracts a single frame at 2 seconds from the input video
2. **Screenshot Creation**: Uses Python/PIL to create a PNG with eye icon + view count
3. **Caption Bar Creation**: Generates a semi-transparent bar with centered caption text
4. **Video Composition**: Uses ffmpeg to overlay all elements onto the video

## Output Format

- **Codec**: H.264 (libx264)
- **Preset**: veryfast (good balance of speed and quality)
- **Audio**: Copy (preserves original audio)
- **Frame Rate**: 30fps (default, configurable)
- **Output Path**: Prints complete file path (e.g., `/path/to/output.mp4`)
- **Temp Files**: Automatically cleaned up after successful processing

## Performance

Processing time depends on:
- Video length and resolution
- CPU performance
- ffmpeg preset (veryfast is used by default)

Typical processing times:
- 1080p, 60s video: ~30-60 seconds
- 1080p, 300s video: ~2-4 minutes
- 4K, 60s video: ~1-2 minutes

## License

This project is provided as-is for educational and personal use.

## Contributing

Feel free to fork, modify, and submit pull requests! Some ideas for contributions:

- Add support for multiple screenshots at different timestamps
- Implement video filters (brightness, contrast, saturation)
- Add text animations or transitions
- Support for custom overlay images
- Batch processing with config files

## Support

For issues, questions, or feature requests, please open an issue on GitHub.

---

**Made with ❤️ for content creators**
