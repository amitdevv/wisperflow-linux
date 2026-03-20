# WisprFlow Local

Free, offline, open-source alternative to [WisprFlow](https://wisprflow.ai) for Linux. Speak anywhere, get clean text - no cloud, no subscription, no data leaves your machine.

**Hold `Ctrl+Shift+Space`, speak, release - text appears in your clipboard and is saved to Obsidian.**

## Quick Start (One Command)

```bash
sudo dnf install ydotool libayatana-appindicator-gtk3 gnome-shell-extension-appindicator portaudio-devel && \
pip install faster-whisper pyaudio numpy evdev pystray Pillow && \
sudo usermod -aG input $USER && \
echo "Log out and back in, then run: python wisprflow.py --daemon"
```

## How It Works

```
Hold Ctrl+Shift+Space → mic records → release → faster-whisper transcribes → clipboard + Obsidian
```

Two modes:

| Mode | How to run | How it works |
|------|-----------|-------------|
| **Daemon** | `python wisprflow.py --daemon` | System tray icon + global hotkey. No terminal needed. |
| **Terminal** | `python wisprflow.py` | Press Enter to start/stop. Good for testing. |

## Features

- **100% offline** - all processing happens locally, no internet needed
- **Global hotkey** - `Ctrl+Shift+Space` works from any app (browser, editor, chat, etc.)
- **System tray icon** - green = ready, red = recording, orange = transcribing
- **Obsidian integration** - daily notes with timestamped bullet points
- **Clipboard copy** - transcription auto-copied, ready to paste
- **Wayland + X11** - works on both via evdev + parecord
- **100+ languages** - auto-detection or specify with `--language`
- **Multiple models** - trade speed for accuracy based on your hardware

## RAM & Performance

Tested on Intel i5-10210U (4 cores), 16GB RAM, Fedora 43.

| Model | RAM Usage | Transcription Speed | Quality | Best For |
|-------|----------|-------------------|---------|---------|
| `tiny` | ~300 MB | ~0.7s for 10s audio | Basic | Quick notes, fast hardware |
| `base` | ~500 MB | ~1.2s for 10s audio | OK | Everyday use on low-end hardware |
| `small` | ~625 MB | ~4s for 25s audio | Good | **Recommended for most users** |
| `medium` | ~2.5 GB | ~8s for 25s audio | Great | When accuracy matters |
| `large-v3-turbo` | ~2.5 GB (INT8) | ~6s for 25s audio | Near-best | 16GB+ RAM systems |

Models download automatically on first run. The `small` model (~500MB download) is the default.

## Installation

### Prerequisites

- Linux (tested on Fedora 43, should work on Ubuntu/Arch/etc.)
- Python 3.10+
- PipeWire or PulseAudio (default on modern distros)
- A microphone

### Step 1: System packages

**Fedora:**
```bash
sudo dnf install ydotool libayatana-appindicator-gtk3 gnome-shell-extension-appindicator portaudio-devel
```

**Ubuntu/Debian:**
```bash
sudo apt install ydotool libayatana-appindicator3-1 gnome-shell-extension-appindicator portaudio19-dev pulseaudio-utils
```

**Arch:**
```bash
sudo pacman -S ydotool libappindicator-gtk3 portaudio
```

### Step 2: Python packages

```bash
pip install faster-whisper pyaudio numpy evdev pystray Pillow
```

### Step 3: Permissions

```bash
# Required for global hotkey detection (reads keyboard via /dev/input)
sudo usermod -aG input $USER

# IMPORTANT: Log out and log back in for this to take effect
```

### Step 4: Run

```bash
git clone https://github.com/amitdevv/wisperflow-linux.git
cd wisperflow-linux
python wisprflow.py --daemon
```

## Usage

### Daemon Mode (recommended)

```bash
python wisprflow.py --daemon                    # default (small model)
python wisprflow.py --daemon --model tiny       # faster, less accurate
python wisprflow.py --daemon --model medium     # slower, more accurate
python wisprflow.py --daemon --language auto    # auto-detect language
python wisprflow.py --daemon --language hi      # Hindi
python wisprflow.py --daemon --no-save          # don't save to Obsidian
python wisprflow.py --daemon --no-clipboard     # don't copy to clipboard
```

Then from any app: **hold `Ctrl+Shift+Space`**, speak, **release**.

### Terminal Mode

```bash
python wisprflow.py                             # interactive mode
python wisprflow.py --model tiny                # use tiny model
```

Press `Enter` to start recording, `Enter` again to stop.

### All Options

| Flag | Description |
|------|------------|
| `--daemon` | Run as background daemon with tray icon + hotkey |
| `--model MODEL` | Whisper model: `tiny`, `base`, `small` (default), `medium`, `large-v3-turbo` |
| `--language LANG` | Language code (`en`, `hi`, `es`, etc.) or `auto` for detection |
| `--save-dir PATH` | Where to save transcripts (default: Obsidian vault) |
| `--no-save` | Don't save transcripts to disk |
| `--no-clipboard` | Don't copy to clipboard |
| `--type` | Auto-type text into focused app via ydotool |
| `--device N` | Use specific audio input device (see `--devices`) |
| `--devices` | List available audio input devices |

## Auto-Start on Login (systemd)

```bash
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/wisprflow.service << 'EOF'
[Unit]
Description=WisprFlow Local - Voice Dictation
After=graphical-session.target pipewire.service

[Service]
Type=simple
ExecStart=/usr/bin/sg input -c "/usr/bin/python3 /path/to/wisprflow.py --daemon --model small"
WorkingDirectory=/path/to/wisperflow-linux
Restart=on-failure
RestartSec=3
Environment=DISPLAY=:0
Environment=XDG_SESSION_TYPE=wayland
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=graphical-session.target
EOF

# Edit the paths above, then:
systemctl --user daemon-reload
systemctl --user enable --now wisprflow.service
```

### Service Commands

| Command | What it does |
|---------|-------------|
| `systemctl --user start wisprflow` | Start |
| `systemctl --user stop wisprflow` | Stop |
| `systemctl --user restart wisprflow` | Restart |
| `systemctl --user status wisprflow` | Check status |
| `journalctl --user -u wisprflow -f` | View live logs |

## Obsidian Integration

Transcriptions are saved as daily notes (configurable with `--save-dir`).

Each day gets one file (`2026-03-20.md`) with bullet points:

```markdown
---
date: 2026-03-20
type: voice-transcripts
---

# Transcripts - March 20, 2026

- **15:45:46** - Hi, hello hello
- **15:45:57** - What are you guys doing currently today?
- **16:10:30** - I need to finish the API integration by tomorrow
```

Works whether Obsidian is open or not - it's just markdown files.

## Architecture

```
┌─────────────┐     ┌──────────┐     ┌───────────────┐     ┌──────────┐
│ evdev        │────>│ parecord │────>│ faster-whisper │────>│ wl-copy  │
│ (hotkey)     │     │ (mic)    │     │ (STT)          │     │ (clipboard)│
└─────────────┘     └──────────┘     └───────────────┘     └──────────┘
                                            │
                                            ▼
                                     ┌──────────────┐
                                     │ Obsidian .md  │
                                     └──────────────┘
```

| Component | Tool | Why |
|-----------|------|-----|
| Global hotkey | `evdev` | Works on Wayland + X11 (kernel-level) |
| Audio capture | `parecord` | Native PipeWire/PulseAudio, separate process |
| Speech-to-text | `faster-whisper` | 4x faster than OpenAI Whisper, INT8 quantization |
| Clipboard | `wl-copy` / `xclip` | Wayland-first with X11 fallback |
| System tray | `pystray` | Cross-desktop (GNOME, KDE, etc.) |
| Auto-typing | `ydotool` | Works on Wayland via /dev/uinput |

## vs WisprFlow

| | WisprFlow | WisprFlow Local |
|---|---|---|
| Price | $15/month | Free |
| Privacy | Cloud (audio sent to servers) | 100% local |
| Internet | Required | Not needed |
| RAM | ~800 MB (idle) | ~300-625 MB (active) |
| Platforms | Mac, Windows, iOS, Android | Linux |
| AI cleanup | Yes (Flow mode) | Coming soon (Ollama) |
| Languages | 100+ | 100+ |

## Troubleshooting

**"No keyboard found"** - You're not in the `input` group. Run `sudo usermod -aG input $USER` and log out/in. Quick workaround: `newgrp input` before running.

**No tray icon on GNOME** - Install and enable the AppIndicator extension:
```bash
sudo dnf install gnome-shell-extension-appindicator
# Then enable "AppIndicator and KStatusNotifierItem Support" in GNOME Extensions app
```

**ALSA/GTK warnings in logs** - Cosmetic and harmless. They don't affect functionality.

**Wrong language detected** - Use `--language en` (or your language code) instead of auto-detect.

**High latency** - Switch to a smaller model: `--model tiny` or `--model base`.

## Future Plans

- [ ] LLM text cleanup via Ollama (remove filler words, fix grammar - "Flow mode")
- [ ] Auto-type into focused app (ydotool integration)
- [ ] Custom hotkey configuration
- [ ] Per-app tone adjustment

## License

MIT
