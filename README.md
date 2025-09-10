# PresencePulse 🟢

**PresencePulse** is a lightweight GNOME desktop app that keeps your Microsoft Teams status active by launching a dedicated Chromium session and simulating periodic activity. Designed for Linux environments (especially NixOS), it avoids synthetic input detection and integrates cleanly with your desktop.

---

## 🚀 Features

- Launches Chromium in **app mode** with a clean, minimal UI
- Uses a **dedicated browser profile** for isolation and persistence
- Periodically injects **mousemove events** to prevent idle status
- Configurable **window size, and position**

## Development Environment

The project uses `flake.nix` and `.envrc` to configure and manage the development environment.

---


## 🧰 Requirements

- Linux (tested on NixOS, should work on most distros)
- `chromium` executable in `$PATH`

---
