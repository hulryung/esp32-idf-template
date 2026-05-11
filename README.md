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
