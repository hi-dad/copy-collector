# Copy Collector

<img src="docs/images/icon.png" alt="Copy Collector app icon" width="128">

**A tiny Mac menu bar app: copy several things while you read, then paste them all with one ⌘V.**

<img src="docs/images/ad.gif" alt="Copy Collector ad: copy three sentences from a web page and they stack up in a list; one Command-V pastes them all into Notes; dictation types as normal; Command-C with nothing selected clears the list; a full list clears itself after 5 minutes" width="720">

### [⬇️ Download Copy Collector](https://github.com/hi-dad/copy-collector/releases/latest/download/CopyCollector.dmg)
Free · macOS 13 or newer · always the latest version

## Install

1. Open **CopyCollector.dmg** and drag Copy Collector into **Applications**.
2. Open it. When macOS says it can't verify the app, click **Done**, then go to **System Settings → Privacy & Security** and click **Open Anyway** (once).
3. Turn on **Input Monitoring** for Copy Collector when asked, so it can tell when you copy and paste.

## How to use it

- Press **⌃⌥C** (or click the circle in the menu bar) to start collecting.
- **⌘C** each thing you want. The number goes up.
- **⌘V** pastes everything at once and starts a fresh pile. A single item stays, so you can paste it again and again.
- With 2 or more waiting, a small list pops up so you know. If you forget, the pile clears itself after 5 minutes without a new copy.
- Click the circle to see, copy or remove items, or change the format (plain, quote, numbered).

Only ⌘C adds to the pile, so it works alongside voice-to-text dictation apps that paste through the clipboard. It never collects passwords, and it ignores images and files. Nothing leaves your Mac.

**Update:** download again and replace the app. **Remove:** circle → gear → **Quit**, then drag it to the Trash.

<details><summary>Build it yourself</summary>

Needs the Xcode Command Line Tools (`xcode-select --install`).

```bash
./build.sh        # builds, installs to Applications and opens it
./build.sh dist   # also makes dist/CopyCollector.dmg
```

</details>

MIT License
