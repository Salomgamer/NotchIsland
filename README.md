# NotchIsland (iPhone 11 Dynamic Island Alternative)

A floating, persistent pill interface built with Swift and SwiftUI that snaps directly under the iPhone 11 notch to display focus timers, media playback, and battery indicators over any app.

---

## Cloud Build: GitHub Actions macOS Runner + Google Drive Upload

Because Apple requires macOS to compile iOS apps, this project uses **GitHub Actions macOS virtual runners** to automatically build the Xcode project, package it into an `.ipa`, and upload it straight to your **Google Drive** (and GitHub Artifacts).

---

### Step 1: Push this Project to GitHub

1. Create a repository at [github.com/new](https://github.com/new) named `NotchIsland` (Public or Private).
2. Open PowerShell in this folder:
   ```powershell
   cd C:\Users\crown\NotchIsland
   git remote add origin https://github.com/<YOUR-USERNAME>/NotchIsland.git
   git push -u origin main
   ```
   *(Or simply run `.\setup_github.ps1`)*

---

### Step 2: Set up Automatic Google Drive Upload (Optional but Recommended)

To have GitHub Actions automatically send the built `.ipa` to your Google Drive:

1. **Enable Google Drive API & Create a Service Account:**
   * Go to the [Google Cloud Console](https://console.cloud.google.com/).
   * Search for **Google Drive API** and click **Enable**.
   * Go to **APIs & Services > Credentials** → Click **Create Credentials** → **Service Account**.
   * After creating it, click on the Service Account → go to the **Keys** tab → **Add Key** → **Create New Key (JSON)**. This downloads a `.json` key file to your PC.
2. **Create a Folder in Google Drive:**
   * Go to [drive.google.com](https://drive.google.com/) and create a folder (e.g. `iOS Builds`).
   * Right-click the folder → **Share** → paste the **Service Account email** (`...iam.gserviceaccount.com` found inside your JSON file) and give it **Editor** permissions.
   * Open the folder and copy the **Folder ID** from your browser address bar:
     `https://drive.google.com/drive/folders/<THIS_IS_THE_FOLDER_ID>`
3. **Add Secrets to your GitHub Repository:**
   * In your GitHub repo, go to **Settings > Secrets and variables > Actions**.
   * Add Repository Secret:
     * Name: `GDRIVE_CREDENTIALS` → Value: (Paste the entire contents of your downloaded `.json` key file)
     * Name: `GDRIVE_FOLDER_ID` → Value: (Paste your Google Drive Folder ID)

---

### Step 3: Trigger the Build & Get your `.ipa`

1. Once pushed, go to the **Actions** tab on your GitHub repository.
2. Click on the running workflow: **Build NotchIsland IPA**.
3. The virtual Mac will:
   * Generate the Xcode project with `xcodegen`.
   * Compile the Swift code using `xcodebuild` targeting iOS.
   * Package `NotchIsland.ipa`.
   * Upload `NotchIsland.ipa` to your **Google Drive** folder automatically.
   * Also save a copy under **Artifacts** on GitHub.

---

## Installing the `.ipa` onto your iPhone 11 (Windows)

1. Download **[Sideloadly](https://sideloadly.io/)** (free for Windows).
2. Connect your iPhone 11 via USB cable and trust your PC.
3. Drag and drop `NotchIsland.ipa` (from your Google Drive or GitHub Artifacts) into Sideloadly.
4. Enter your Apple ID and click **Start**.
5. On your iPhone:
   * Go to **Settings > General > VPN & Device Management** and trust your Apple ID certificate.
   * Open **Notch Island** and tap **Launch Floating Island**!
