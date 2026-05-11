# esp32-idf-template

Reproducible ESP-IDF v5.3 workspace for ESP32 (WROOM-32E). QEMU emulation + real device flash. macOS-native toolchain.

## What you get

- ESP-IDF v5.3 (LTS) cloned locally, isolated from the system
- Xtensa GCC toolchain for ESP32 (extensible to ESP32-S3 / C3 / C6 / H2)
- QEMU (xtensa + riscv32) for board-less emulation
- Two starter projects: `hello_world`, `blink`
- One-shot `setup.sh` and a `get_idf` shell alias

## Requirements

- macOS (tested on Apple Silicon, macOS 26)
- [Homebrew](https://brew.sh)
- Git, ~5 GB free disk

## Install

```bash
git clone https://github.com/hulryung/esp32-idf-template.git
cd esp32-idf-template
./setup.sh
```

The script installs brew deps, clones ESP-IDF into `./esp-idf/` (gitignored), installs the toolchain + QEMU, and appends a `get_idf` alias to your `~/.zshrc`.

To install additional chip targets:

```bash
IDF_TARGETS="esp32 esp32s3 esp32c3 esp32c6" ./setup.sh
```

## Usage

Open a new terminal:

```bash
get_idf                              # activate ESP-IDF env (idf.py becomes available)
cd projects/hello_world
idf.py set-target esp32              # or esp32s3 / esp32c3 / ...
idf.py build
```

### Emulate with QEMU (no hardware needed)

```bash
idf.py qemu                          # Ctrl+A then X to quit
```

Verified output on hello_world:

```
Hello world!
This is esp32 chip with 2 CPU core(s), WiFi/BTBLE, silicon revision v3.0, 2MB external flash
```

### Flash to a real ESP32-WROOM-32E

1. Plug the board in via USB.
2. Find the serial port: `ls /dev/cu.usb*` (usually `cu.usbserial-XXXX` or `cu.SLAB_USBtoUART`).
3. If the port doesn't appear, install the USB-UART driver (CP210x or CH340) and approve it in System Settings → Privacy & Security.

```bash
idf.py -p /dev/cu.usbserial-XXXX flash monitor    # Ctrl+] to exit monitor
```

## VSCode workflow

The repo ships with a `.vscode/` config that integrates the official Espressif ESP-IDF extension. First-time setup:

1. Install [VSCode](https://code.visualstudio.com), open this folder, and accept the recommended extensions prompt (`espressif.esp-idf-extension`, `ms-vscode.cpptools`).
2. The Espressif extension will pick up `${workspaceFolder}/esp-idf` automatically thanks to the workspace `idf.espIdfPath` setting.

**Build / Flash / Monitor** — Cmd+Shift+P → `Tasks: Run Task`:

| Task | What it does |
|---|---|
| `IDF: Set target` | Prompts for project + chip, runs `idf.py set-target` |
| `IDF: Menuconfig` | sdkconfig TUI in the terminal |
| `IDF: Build` (default build task, ⇧⌘B) | `idf.py build` |
| `IDF: Flash + Monitor` | Prompts for serial port and project |
| `IDF: QEMU run` | Emulate without hardware |

All tasks prompt for which project (`hello_world` / `blink`). To add more, edit `.vscode/tasks.json` → `inputs[projectName].options`.

**Debug** (F5):

- **`QEMU Debug (xtensa-esp32-elf-gdb)`** — no hardware needed. Starts QEMU with `--gdb`, attaches GDB, breaks at `app_main`. Stable across IDF/toolchain upgrades because GDB launches via `scripts/idf-gdb.sh`.
- **`ESP-IDF: JTAG Debug (FT2232H + OpenOCD)`** — real hardware via JTAG. Defaults to OpenOCD config `interface/ftdi/esp32_devkitj_v1.cfg` + `target/esp32.cfg`. For other FTDI breakouts (Adafruit FT232H, Tigard, ESP-Prog, etc.), edit `idf.openOcdConfigs` in `.vscode/settings.json` — common alternatives:
  - ESP-Prog: `interface/ftdi/esp_usb_jtag.cfg` (newer) or `interface/ftdi/esp32_devkitj_v1.cfg`
  - Tigard: `interface/ftdi/tigard.cfg`
  - C232HM cable: `interface/ftdi/c232hm-edhsl-0.cfg`

**JTAG wiring for ESP32-WROOM-32E**

| Signal | ESP32 GPIO | FT2232H pin (typical) |
|---|---|---|
| TCK  | GPIO13 | ADBUS0 |
| TMS  | GPIO14 | ADBUS3 |
| TDI  | GPIO12 | ADBUS1 |
| TDO  | GPIO15 | ADBUS2 |
| GND  | GND    | GND |

Note: GPIO12 is a strapping pin — pull it low (or leave floating) at reset, or you may brick boot mode until reflashed.

## Projects

| Path | Description |
|---|---|
| `projects/hello_world` | Prints "Hello world!" + chip info, then restarts. Good for verifying the toolchain. |
| `projects/blink` | Blinks the on-board LED. Configure GPIO via `idf.py menuconfig` → *Example Configuration*. |

Add your own under `projects/<name>/` — each is a self-contained ESP-IDF project (`CMakeLists.txt` + `main/`).

## Layout

```
esp32-idf-template/
├── setup.sh           # one-shot installer
├── esp-idf/           # ESP-IDF SDK (cloned by setup.sh, .gitignored)
└── projects/
    ├── hello_world/
    └── blink/
```

## License

Project scaffolding is MIT. ESP-IDF and example code retain their original Espressif licenses (Apache-2.0 / public domain).
