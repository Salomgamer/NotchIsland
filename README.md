# Dynamic Notch (iPhone 11 Dynamic Island Alternative)

[![iOS 15.0+](https://img.shields.io/badge/iOS-15.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Version 3.7](https://img.shields.io/badge/DynamicNotch-v3.7-green.svg)](https://github.com/Salomgamer/NotchIsland/releases/tag/v3.7)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

**Dynamic Notch** brings the real **Apple Dynamic Island** experience to the iPhone 11, iPhone XR, iPhone 12, iPhone 13, and all notched iOS devices. 

Sitting invisibly flush under the physical camera notch, Dynamic Notch delivers live multipurpose playback, animated equalizers, split dual-activity countdowns, hardware battery diagnostics, and one-tap controls without ever disrupting your workflow.

---

## Key Features

### 1. Simultaneous Multipurpose Readout
* **Leading**: Song artwork thumbnail with branded source application badge (Spotify green waveform, YouTube red play, Safari blue compass, Stremio purple film, Apple Music note).
* **Center**: Song / Podcast / Caller title with dynamic smooth ticker marquee auto-scrolling when overflowing available width.
* **Trailing**: Live Equalizer waveform + Connected Audio Route icon + Exact 1% integer Battery readout (`98%` ⚡).

### 2. In-Place Expand & Spring Physics (No App Disruption)
* **Zero App Restore on Click**: Tapping the floating island expands it into an interactive HUD directly in place without kicking you out to the main app (`restoreUserInterfaceForPictureInPictureStopWithCompletionHandler` intercepted with `completionHandler(false)`).
* **Transparent Excess Margins**: The PiP canvas is 100% transparent (`isOpaque = false`, `backgroundColor = .clear`); only the centered pill is visible.

### 3. Split Island Dual-Activity Mode
* Automatically splits into concurrent readouts when multiple activities run together (e.g. listening to music while a Focus Timer is counting down).
* Displays a live orange countdown badge alongside the music visualizer and battery percentage.

### 4. Direct In-Island AirPlay & Audio Route Picker
* Embedded `AVRoutePickerView` behind the route indicator. Tapping the route badge inside the expanded island immediately summons Apple's native audio output sheet to switch between AirPods Pro, AirPods Max, CarPlay, Beats, Bluetooth, or iPhone speakers.

### 5. Universal MediaRemote Synchronization
* Listens directly to Apple's private `MediaRemote.framework` and hardware `AVAudioSession`.
* Seamlessly syncs Now Playing metadata, album artwork, and play/pause status across **Spotify / EeveeSpotify**, **YouTube**, **Safari**, **Stremio**, **Apple Music**, **SoundCloud**, **Netflix**, and **Twitch** with zero Android-only broadcast settings required.

### 6. Interactive Playback Remote & Scrubber
* Previous, Play/Pause, and Next transport buttons.
* Monospaced elapsed (`1:24`) and countdown (`-2:18`) timers.
* Fluid drag-to-seek scrubber with an Apple Music-style circular thumb knob.
* 1-Tap App Launcher: Tapping the album artwork directly launches the active music/video app.

### 7. 9 OLED & Frosted Glass Background Styles
* **OLED Black**: Pure deep black with customizable opacity.
* **Frosted Glass**: Translucent iOS blur with specular highlight gradient.
* **Artwork Adaptive**: Dynamically samples the dominant accent color from the current album art.
* **Midnight Navy**, **Dark Obsidian**, **Deep Crimson**, **Cyber Neon**, **Aurora Borealis**, and **Sunset Horizon**.
* Live opacity slider (40%–100%).

### 8. Dynamic Mode Arbitration & Blank / Stealth Notch Mode
* **Arbitration Engine**: Intelligently routes priority: Incoming Call > Active Call > Media Stream > Focus Timer > Stopwatch > Blank Stealth.
* **Blank Stealth Mode**: Sits as a completely invisible OLED cover over the physical notch when idle, springing open whenever audio starts, a timer runs, or the charger is connected.
* Tapping the blank notch expands into a sleek **System Quick Dashboard** (battery, connected audio, torch, media launcher).

### 9. Kernel IOKit Hardware Battery Diagnostics
* Reads exact 1% integer capacity directly from kernel `IOPSCopyPowerSourcesInfo` (bypassing iOS 5% quantization).
* Displays live charging wattage (e.g., `18W` / `20W` fast charging), live voltage (`3.92V`), current draw (`+/-1,850mA`), battery temperature in °C, and charge cycle counts.
* **100% Full Charge Alert**: Notifies upon reaching full battery to protect cell health.
* **Thermal Protection Alert**: Immediate banner if battery exceeds 42°C.
* **Pulsing Battery Breathing**: Charging bolt gently breathes while connected to power; pulses red below 10%.

### 10. Emergency SOS Morse Strobe Beacon
* One-tap international Morse code (`... --- ...`) torch beacon with live Dynamic Island alert banner.
* 4-step discrete torch brightness controls (`25%`, `50%`, `75%`, `100%`).

### 11. Clipboard HUD Notch Alerts
* Automatically detects text copied to the iOS clipboard and pops down a brief preview banner with a clipboard glyph.

### 12. Gesture Engine & Apple Taptic Engine
* **Single Tap**: Expand / Collapse in place.
* **Double Tap**: Configurable quick action (Play/Pause, Next Track, Toggle Torch, Toggle SOS, Toggle Silent, Cycle Visualizer, Expand/Collapse).
* **Long Press**: Cycle active modes with haptic vibration.
* **Taptic Engine Showcase**: Interactive tactile tester for selection, expand spring, charge surge, and double-tap feedback.

### 13. Pixel Calibrator & Device Notch Presets
* Precision presets for:
  * **iPhone 11 / XR**: `156 × 36 pt` (Radius: 18pt)
  * **iPhone 12 / 12 Pro**: `150 × 35 pt` (Radius: 17.5pt)
  * **iPhone 13 / 14**: `138 × 34 pt` (Radius: 17pt)
  * **Custom Notch**: Width, Height, and Corner Radius sliders.

---

## Cloud Build & Automation

Built and packaged automatically on **GitHub Actions macOS virtual runners** using `xcodegen` and `xcodebuild`:

1. Generates the Xcode project with `xcodegen generate`.
2. Compiles unsigned release binaries for iOS 15.0+.
3. Packages the application bundle into `DynamicNotch.ipa`.
4. Uploads to GitHub Actions Artifacts and automatically releases tagged `.ipa` builds.

---

## Installation via Sideloading (Windows / macOS)

### Option A: Sideloadly (Recommended for Windows)
1. Download [Sideloadly](https://sideloadly.io/) on your PC.
2. Connect your iPhone via USB cable.
3. Drag and drop `DynamicNotch.ipa` (from your `Downloads` folder) into Sideloadly.
4. Enter your Apple ID and click **Start**.
5. On your iPhone:
   * Go to **Settings > General > VPN & Device Management** and trust your Apple ID certificate.
   * Open **Dynamic Notch** and tap **Launch Dynamic Notch**!
   * Swipe up to go to your Home Screen; position the island flush under the camera notch.

### Option B: AltStore / TrollStore / Scarlet
* Open AltStore or TrollStore on your device.
* Select `DynamicNotch.ipa` to install with persistence.

---

## License
MIT License. Created with love for iPhone 11 and notch device owners.
