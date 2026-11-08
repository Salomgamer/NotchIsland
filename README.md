# Dynamic Notch (iPhone 11 Dynamic Island Alternative)

[![iOS 15.0+](https://img.shields.io/badge/iOS-15.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Version 8.1](https://img.shields.io/badge/DynamicNotch-v8.1_BubbleTouchAction-green.svg)](https://github.com/Salomgamer/NotchIsland/releases/tag/v8.1)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

**Dynamic Notch** brings the real **Apple Dynamic Island** experience to the iPhone 11, iPhone XR, iPhone 12, iPhone 13, and all notched iOS devices. 

Sitting invisibly flush under the physical camera notch, Dynamic Notch features **Apple Jindo Reverse-Engineered Architecture**: true Dual-Island Splitting (Major Pill + Detached Orbit Bubble), 20 authentic Apple System Apertures (Apple Pay NFC, AirPods Pro 3-way battery case, AirDrop transfer, Personal Hotspot telemetry, Dual SIM cellular, Uber Rideshare, Flighty Flight Tracker, Food Delivery, Screen Recording, Privacy sensor dots), viral mini-games (Hit The Island Pong with liquid squish physics & Notch Pixel Pet companion), interactive SpringBoard rubberband pull-down stretch & horizontal flick-to-stealth gestures, authentic AudioServices sound chimes, and a Transparent Liquid Glass Wallpaper Engine.

---

## What's New in v8.1 (Bubble Touch: In-Place Expansion & Direct App Launch)

* **Bubble Touch Behavior Engine (No More Accidental App Opening!)**:
  * Tapping the floating island or bubble **no longer opens the Dynamic Notch settings app**!
  * **Option 1: Open Active App (Apple Native)**: Touching the bubble directly launches the app corresponding to what is currently happening (Spotify, Apple Music, Clock Timer, Apple Maps, Phone Call, Wallet, Voice Memos, Uber, Food Delivery), exactly 1:1 with Apple's real Dynamic Island on iPhone 14 Pro / 15 / 16!
  * **Option 2: Expand Dynamic Island In-Place**: Touching the bubble expands the island right at the notch into its full interactive platter with playback scrubber, volume, and control toggles, without displaying the settings dashboard.
  * **Option 3: Smart Adaptive (Recommended)**: Automatically opens the app if external media, call, timer, or navigation is running; smoothly expands the island in-place if idle or using internal tools (Pong, Pixel Pet, Torch, Battery).
  * **Dual-Island Independent Bubble Arbitration**: Tapping the Major Pill opens/expands the primary activity (e.g., Spotify), while tapping the Detached Orbit Bubble opens/expands the secondary activity (e.g., Apple Clock Timer).
  * Registered complete `LSApplicationQueriesSchemes` in `Info.plist` for seamless, instant app launching across all major iOS services.

---

## What's New in v8.0 (Apple Jindo Definitive Masterpiece Edition)

* **Hit The Island (Pong Mini-Game) & Liquid Squish Physics**:
  * Reverse-engineered the viral Dynamic Island Pong game directly into the physical iPhone notch!
  * Interactive bouncing ball rallies off the notch island with Pong sound effects (`AudioServicesPlaySystemSound(1057)`), medium haptic feedback, and authentic Apple liquid-spring squish bounce (`scaleEffect(1.08 -> 1.0)`).
  * Real-time score counter and high-score retention.
* **Dynamic Island Pixel Pet (Notch Companion)**:
  * An adorable virtual pixel companion perching directly on the top curvature of your physical iPhone notch.
  * 4 selectable companions: Cat 🐱, Puppy 🐶, Fox 🦊, Axolotl 🦎.
  * Interactive behaviors: walks along the notch, jumps, dances, and purrs with delicate double-pulse haptics when petted/tapped.
* **AirDrop File Transfer System Aperture**:
  * Reverse-engineered iOS AirDrop transfer HUD featuring dynamic circular progress ring (`airDropProgress`), sender identity ("Sarah's iPhone", "MacBook Pro"), item count telemetry ("4 Photos and Videos"), and 1-tap "Accept" or "Open in Photos" action.
* **Personal Hotspot Telemetry HUD**:
  * Dynamic Island hotspot aperture tracking active connected tethering devices, real-time upload speed (↑ 1.4 MB/s) and download speed (↓ 5.2 MB/s) throughput telemetry, and network management actions.
* **Dual SIM & Cellular Network Telemetry**:
  * Real-time dual SIM status monitoring Primary SIM ("Verizon 5G UW", 4 bars) and Secondary SIM ("T-Mobile LTE", 3 bars), 5G Ultra Wideband badge, and 1-tap active SIM switching.
* **SpringBoard Dynamic Island Audio Feedback**:
  * Authentic Apple AudioServices system chimes: `1104` whoosh expand sound on island pull-down, `1105` snap collapse sound on tap/dismiss, `1111` Face ID chime, and `1008` AirPods spatial connection chord.
* **iOS 18 Flashlight 2D Spread Geometry**:
  * Complete reverse engineering of iOS 18's Dynamic Island Flashlight HUD: dual 2D controls featuring dynamic beam spread angle slider (10° to 100°) alongside beam brightness intensity.

---

## What's New in v7.0 (Apple Jindo Reverse Engineered Edition)

* **Apple Jindo True Dual-Island Splitting (Minimal Multi-Item Mode)**:
  * Dynamically splits into **Two Independent Physical Elements**:
    * **Major Pill (Left)**: `124 × 36 pt` continuous squircle hosting primary activity (Now Playing artwork + live frequency visualizer, Call elapsed timer, or Turn-by-Turn Navigation).
    * **Detached Orbit Bubble (Right)**: `36 × 36 pt` circular squircle physically separated by an authentic 8pt gap, hosting secondary activity (Focus Timer countdown, Stopwatch ticker, Voice Memo red pulsing dot, Sports match score, Battery level, Hardware Privacy Dot, or Personal Hotspot).
  * Independent tap arbitration: tap Major Pill to expand primary activity; tap Orbit Bubble to expand secondary activity with fluid Apple spring physics.
* **16 Authentic Reverse-Engineered System Apertures**:
  * **Apple Pay / Wallet NFC**: Authentic Apple Card styling with silver gradient, concentric animated wireless radio waves, 3-phase interactive authentication flow ("Hold Near Reader" -> "Double Click Side Button" -> bold green "Done" checkmark with native Apple Pay double-click chime).
  * **AirPods Pro 3-Component Battery Case HUD**: 3D-styled Left AirPod (`L: 96%`), Charging Case (`Case: 100% ⚡`), and Right AirPod (`R: 92%`) with Spatial Audio / Noise Control status.
  * **Uber / Rideshare Live Activity (`ActivityKit`)**: Car en route trajectory track with moving vehicle icon, live ETA, car model ("Black Toyota Prius"), driver rating ("David • 4.98 ★"), and high-contrast license plate badge (`[ 7XYZ890 ]`).
  * **Flighty Flight Tracker Live Activity**: Route trajectory line (`SFO` ➔ `JFK`) with airplane climbing along trajectory, flight number (`UA 2408`), gate (`B22`), arrival countdown, and green "On Time" status capsule.
  * **DoorDash Food Delivery Live Activity**: 4-step progress timeline (Placed -> Kitchen -> Out for Delivery -> Arrived), restaurant name (`Shake Shack`), courier info (`Alex on E-Bike`), and live ETA.
  * **Screen Recording Bezel Aperture**: Animated 3-2-1 countdown, live elapsed recording timer (`00:18`), pulsing red recording indicator, and 1-tap Stop Recording action saving directly to Photos.
  * **Hardware Sensor Privacy Bezel Indicators**: Authentic vibrant orange microphone and green camera dots placed directly on the notch bezel edge whenever sensors are active.
  * **Apple Watch & Mac Auto-Unlock HUD**: Watch icon with padlock snapping open and "Unlocked by Apple Watch".
  * **Cellular SIM Switched HUD**: Dual antenna bars with network band indicator.
* **SpringBoard Interactive Physics & Gestures**:
  * **Pull-Down Rubberband Stretch**: Pull down on the island with authentic quadratic rubberband spring resistance; stretch beyond threshold to expand smoothly into interactive HUD.
  * **Horizontal Flick to Stealth**: Flick left or right to tuck the island flush into the physical notch; a subtle stealth indicator allows instant 1-tap restore.
  * **Long-Press & Double-Tap Fast Actions**: Long press to deep-expand; double-tap to cycle accent themes, toggle split mode, play/pause, or copy track info.

---

## What's New in v6.1 (Transparent Liquid Glass & In-PiP Actions)

* **Transparent Liquid Glass Wallpaper Engine**:
  * Users can select their home screen / lock screen wallpaper directly from Photos.
  * Dynamically extracts and aligns the top slice beneath the physical notch.
  * Renders with fluid optical blur, dual specular reflection sheen, meniscus highlight gradients, and caustic liquid shimmer.
  * Creates an optical illusion of a 100% transparent liquid glass notch floating seamlessly over your wallpaper.
  * Includes 5 built-in liquid glass presets (Astral OLED, Liquid Prism, Ocean Glass, Frosted Acrylic, Sunset Amber) with custom blur, glass tint, and specular sliders.
* **In-PiP Interactive Actions Center**:
  * Tapping the notch expands directly inside Picture-in-Picture without opening the Dynamic Notch app or switching away from your active screen.
  * Interactive in-place actions: Play/Pause music, toggle Torch, start 25m Focus Timer, toggle Silent mode, adjust volume, and collapse chevron.
  * Tapping album artwork toggles play/pause in place instead of launching external apps.
* **Universal Multi-Activity Auto-Detection**:
  * Detects and auto-switches interfaces for every activity: Phone & VoIP Calls, Media streaming, Torch, Voice Memo recording, Focus Timer, Stopwatch, Navigation, and Live Sports.

---

## What's New in v6.0 (Adaptive Device Engine)

* **CallKit Real-Time Phone & VoIP Call Adaptation**:
  * Utilizes Apple's native `CallKit` (`CXCallObserver`) to detect incoming cellular and VoIP calls in real time.
  * Synchronized telephone ring haptics and alert chime (`HapticService.startCallRingtone()`).
  * Oscillating ringing phone glyph with ripple wave halo.
  * Expands to `242 × 78 pt` with genuine Apple-style Decline (red) and Accept (green) capsule buttons.
  * Live connected call elapsed timer, active green audio waveform, microphone mute, speaker switcher, and 1-tap end call button.
* **Intelligent Notification Auto-Expansion**:
  * Floating notch pill dynamically expands upon any system or app notification (screenshots via `UIApplication.userDidTakeScreenshotNotification`, charger plug/unplug, AirPods / Bluetooth audio route changes, thermal protection warnings, clipboard copy, and focus timer finishes).
  * Auto-collapses with Apple spring physics after 3.8s, or collapses instantly when tapped.
* **Hardware Power State Adaptation**:
  * Live charger connection and disconnection alerts with exact wattage readout.

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

### 12. Dynamic Island Notification Test Lab
* Instant one-tap simulation playground to test all native Dynamic Island triggers directly on demand:
  * ⚡ **Fast Charge Surge**: Triggers the authentic charging pill animation with wattage readout.
  * 🎧 **AirPods Pro Connection**: Displays spatial audio indicator and connected earbud battery percentage.
  * 🪫 **Low Battery Alert (10%)**: Pulsing red alert banner.
  * 🔋 **Full Charge Preservation (100%)**: Green shield alert to optimize cell lifespan.
  * 🌡️ **Thermal Protection**: Warning banner when device exceeds 42°C.
  * ⏱️ **Focus Timer Finish**: Session completion alert with chime and vibration.
  * 📋 **Clipboard HUD**: Live snippet preview banner.
  * 🔔 **Silent / Ring Switch**: Toggle mute with Apple-style HUD.
  * 🔊 **Volume HUD**: Dynamic Notch Volume slider.
  * 📞 **Incoming Call**: Full incoming call sheet with Accept & Decline actions.

### 13. 4 Audio Visualizer Styles & Speed Dynamics
* **Classic Bars**: Multi-column vertical equalizer.
* **Audio Waveform**: Acoustic speech & instrument voice waveform.
* **Breathing Dot**: Minimalist ambient breathing dot.
* **Neon Frequency**: Spectral shimmer frequency bars with cyan-to-accent neon gradients.
* **Dynamic Speeds**: Gentle, Balanced, or Energetic response frequencies.

### 14. Gesture Engine & Apple Taptic Engine
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
