# NotchIsland (iPhone 11 Dynamic Island Alternative)

A floating, persistent pill interface built with Swift and SwiftUI that snaps directly under the iPhone 11 notch to display focus timers, media progress, and battery indicators over any app.

---

## How to Build the `.ipa` on Windows (No Mac Required)

Because Apple requires macOS to compile iOS apps, this project uses **GitHub Actions** (a free cloud Mac runner) to build the app and package it into an `.ipa` for you automatically.

### Step 1: Create a Repository on GitHub
1. Go to [github.com/new](https://github.com/new).
2. Name the repository: `NotchIsland`.
3. Set it to **Public** or **Private** (both include free GitHub Actions minutes).
4. Do not initialize with README or .gitignore (we already have them). Click **Create repository**.

### Step 2: Push this folder to your GitHub repo
Open PowerShell and run:
```powershell
cd C:\Users\crown\NotchIsland
git branch -M main
git remote add origin https://github.com/<YOUR-USERNAME>/NotchIsland.git
git push -u origin main
```

### Step 3: Download the `.ipa`
1. On your GitHub repository page, click the **Actions** tab.
2. You will see the **Build NotchIsland IPA** workflow running on a macOS runner.
3. Once completed (~2 minutes), click on the completed run and scroll to **Artifacts**.
4. Download **`NotchIsland-IPA.zip`** and extract **`NotchIsland.ipa`**.

---

## How to Install onto your iPhone 11 on Windows

1. Download and install **[Sideloadly](https://sideloadly.io/)** (free tool for Windows).
2. Connect your iPhone 11 to your PC via a USB cable.
3. Open Sideloadly:
   * Drag and drop `NotchIsland.ipa` into the app icon field.
   * Enter your Apple ID (free Apple accounts work).
   * Click **Start**.
4. On your iPhone:
   * Go to **Settings > General > VPN & Device Management** and trust your developer certificate.
   * Open **Notch Island** and tap **Launch Floating Island**!
