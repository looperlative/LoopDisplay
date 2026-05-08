# LoopDisplay

A cross-platform status display for the Looperlative LP1 audio looping device. Shows the real-time state of all eight tracks in a mixing-board style interface, communicating with the device over UDP on the local network.

## Features

- Auto-discovers the LP1 on the LAN via UDP broadcast
- Polls device status at 100 ms intervals
- Displays all eight tracks simultaneously:
  - **State badge** — color-coded REC / DUB / PLAY / STOP / REPL / EMPTY with animation on active states
  - **Loop position** — progress bar showing playback position within the loop
  - **Level** — dB attenuation bar with numeric readout
  - **Pan** — left/right position indicator
  - **Feedback** — decay/overdrive bar with unity marker
- Selected track highlighted with accent border and background tint
- Designed for desktop, Android, and iOS

## Requirements

- Qt 6.5 or later (Core, Gui, Quick, Qml, Network)
- CMake 3.16 or later
- C++20 compiler

## Building

```bash
cmake -B build
cmake --build build
```

### Android / iOS

Configure with the appropriate Qt kit in Qt Creator and deploy normally. The UDP discovery and polling work on both platforms; ensure the app has local network permission on iOS.

## Protocol

The app speaks the Looperlative LP1 UDP control protocol on port 5667. Discovery sends `<query>id</query>` as a broadcast; status is requested with `<query>status compact</query>`. All multi-byte integers in the status packet are big-endian (network byte order).

## License

Copyright (C) 2026 Robert Amstadt

Licensed under the GNU General Public License v3 — see [LICENSE.txt](LICENSE.txt).
