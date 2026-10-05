# 🎧 Local Bulk Audio Converter

A bulk audio converter that runs **entirely in your browser**. It uses [ffmpeg.wasm](https://github.com/ffmpegwasm/ffmpeg.wasm), so your files are never uploaded to any server: all processing happens locally.

It is a single page (`index.html`) with a dark Bootstrap 5 interface.

## Features

- **Bulk conversion**: select or drag and drop multiple files and convert them all at once.
- **Input formats**: MP3, OGG/OGA, Opus, AAC/M4A, WAV, FLAC (and any `audio/*` file ffmpeg can read).
- **Output formats**:

  | Format | Codec | Extension |
  |--------|-------|-----------|
  | MP3 | libmp3lame | `.mp3` |
  | OGG | libvorbis | `.ogg` |
  | Opus (default) | libopus | `.opus` |
  | AAC | FFmpeg native `aac` (AAC-LC) | `.m4a` |
  | WAV | PCM 16-bit | `.wav` |
  | FLAC | flac (lossless) | `.flac` |

- **Quality by bitrate**: from 24 kbps to 320 kbps (24 kbps is only offered for Opus).
- **Encoder effort** (0–4): trade-off between speed and compression for MP3, Opus and FLAC.
- **Max file size**: pick a limit (512 KiB, 1, 2, 5, 10 MiB or custom) and the app computes the bitrate needed to stay under it, verifying the result and retrying up to 4 times. Lossy formats only.
- **Audio adjustments**:
  - Sample rate (48000 / 44100 / 32000 / 24000 / 16000 Hz or original)
  - Channels (original / mono / stereo)
  - Speed ×1 to ×3 without changing pitch (`atempo`)
  - EBU R128 loudness normalization (−16 LUFS)
  - Strip metadata
- **Multithreading**: each thread loads its own ffmpeg instance in a Web Worker (more threads = more RAM).
- **Per-file info**: codec, bitrate, sample rate, channels and duration for both input and output, with a built-in player and download button.
- **Global stats**: size before/after, percentage, remaining, successes, errors and elapsed time.
- **ZIP download** of all results.
- **Automatic recovery**: if an encoder rejects a parameter combination, the conversion is retried with safer settings (the card shows an `adjusted` badge). If an ffmpeg instance crashes, it is rebuilt.
- **Persistent preferences** in `localStorage` (use the 🗑 button to reset them).

## Project structure

```
.
├── index.html
└── core/
    ├── ffmpeg-core.js
    └── ffmpeg-core.wasm
```

The `core/` folder is **not bundled** with `index.html`; you need to add it yourself.

## Getting started

### 1. Get the ffmpeg core

The code uses the `@ffmpeg/core` API (`createFFmpegCore`, `exec`, `reset`, `setLogger`), single-thread build. Download it with npm:

```bash
npm pack @ffmpeg/core
tar -xzf ffmpeg-core-*.tgz
mkdir -p core
cp package/dist/umd/ffmpeg-core.js package/dist/umd/ffmpeg-core.wasm core/
```

Make sure the build includes the `libmp3lame`, `libvorbis` and `libopus` encoders.

### 2. Serve the page over HTTP(S)

It will not work when opened via `file://`, because Web Workers and `.wasm` loading are blocked. Any static server will do:

```bash
# Python
python3 -m http.server 8080

# Node
npx serve .
```

Then open <http://localhost:8080>.

## Usage

1. Pick files with **Select Audio** or drag them onto the drop zone.
2. Choose the output format (**Convert To**), quality and any audio adjustments.
3. Click **Convert**.
4. Download each file individually or all of them with **ZIP**.

## External dependencies (CDN)

- [Bootstrap 5.3.2](https://getbootstrap.com/) (jsDelivr): styling.
- [JSZip 3.10.1](https://stuk.github.io/jszip/) (cdnjs): ZIP generation.

To work offline, download both libraries and update the paths in `index.html`.

## Notes and limitations

- Everything is processed in memory, so very large files or too many threads can exhaust the browser's RAM.
- AAC uses FFmpeg's native encoder (AAC-LC). At equal bitrate, **Opus gives better quality**, especially below 128 kbps; AAC is only worth it for compatibility with older players.
- With the max file size option, if the limit is lower than the format's minimum bitrate, the result is flagged as `over limit`.
- Low bitrates combined with certain sample rates may be rejected by the encoder (e.g. Vorbis or MP3 at 32 kbps or less). The app adjusts the sample rate automatically.

---

