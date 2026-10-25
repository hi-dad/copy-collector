#!/bin/zsh
# Builds CopyCollector.app, installs it to /Applications and relaunches it.
# ./build.sh dist  also makes dist/CopyCollector.dmg to share.
set -e
cd "$(dirname "$0")"
source tools/sparkle.sh && sparkle_fetch   # self-updating (see tools/sparkle.sh)
APP=CopyCollector.app
rm -rf $APP
mkdir -p $APP/Contents/MacOS $APP/Contents/Resources
# Universal binary: Apple Silicon + Intel Macs.
for arch in arm64 x86_64; do
  swiftc -parse-as-library -swift-version 5 -O -target $arch-apple-macos13 "${SPARKLE_SWIFTC_FLAGS[@]}" main.swift -o /tmp/CopyCollector-$arch
done
lipo -create /tmp/CopyCollector-arm64 /tmp/CopyCollector-x86_64 -output $APP/Contents/MacOS/CopyCollector
rm /tmp/CopyCollector-arm64 /tmp/CopyCollector-x86_64
cp AppIcon.icns $APP/Contents/Resources/
cat > $APP/Contents/Info.plist <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Copy Collector</string>
  <key>CFBundleDisplayName</key><string>Copy Collector</string>
  <key>CFBundleIdentifier</key><string>com.danielryan.collect</string>
  <key>CFBundleExecutable</key><string>CopyCollector</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
sparkle_embed $APP
sparkle_plist $APP copy-collector
# Sign with the same local certificate every time so macOS keeps Input Monitoring across rebuilds.
# (Falls back to ad-hoc signing on a Mac without it; then the permission must be re-added after each build.)
# GitHub's release builds sign with Developer ID + hardened runtime + timestamp, as Apple's notarization needs.
if [[ -n "$SIGN_IDENTITY" ]]; then
  sparkle_sign $APP --force --sign "$SIGN_IDENTITY" --options runtime --timestamp
  codesign --force --sign "$SIGN_IDENTITY" --options runtime --timestamp $APP
elif security find-certificate -c "Daniel Ryan Local Signing" >/dev/null 2>&1; then
  sparkle_sign $APP --force --sign "Daniel Ryan Local Signing"
  codesign --force --sign "Daniel Ryan Local Signing" $APP
else
  sparkle_sign $APP --force --sign -
  codesign --force --sign - $APP
fi
echo "Built $APP"

if [[ "$1" == "dist" ]]; then
  rm -rf dist && mkdir -p dist/stage
  cp -R "$APP" dist/stage/
  ln -s /Applications dist/stage/Applications
  hdiutil create -volname "Copy Collector" -srcfolder dist/stage -ov -format UDZO dist/CopyCollector.dmg >/dev/null
  rm -rf dist/stage
  echo "Made dist/CopyCollector.dmg"
fi

# On GitHub's build machines (CI is set there), stop here: the DMG is what gets published.
[[ -n "$CI" ]] && exit 0

# Install: keep only one copy on this Mac.
pkill -x CopyCollector || true
pkill -x ClipList || true   # its name before Copy Collector
pkill -x Collect || true   # the app's old name
rm -rf /Applications/ClipList.app
sleep 1
rm -rf /Applications/Collect.app
rm -rf /Applications/$APP
mv $APP /Applications/
open /Applications/$APP
echo "Installed to /Applications"
