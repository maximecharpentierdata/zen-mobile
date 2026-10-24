#!/usr/bin/env bash
# Builds the app for the iOS Simulator, launches it with demo data and saves screenshots.
# macOS only. Usage: scripts/screenshots.sh <output-dir>
set -euo pipefail

out="${1:-screenshots}"
mkdir -p "$out"

xcodebuild build \
    -project ZenMobile.xcodeproj \
    -scheme ZenMobile \
    -sdk iphonesimulator \
    -configuration Debug \
    -derivedDataPath build \
    CODE_SIGNING_ALLOWED=NO \
    -quiet
app="build/Build/Products/Debug-iphonesimulator/ZenMobile.app"
bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist")"

# The newest plain "iPhone NN" simulator available on this machine.
udid="$(xcrun simctl list devices available -j | python3 -c '
import json, re, sys
devices = json.load(sys.stdin)["devices"]
phones = [d for runtime, ds in devices.items() if "iOS" in runtime for d in ds
          if re.fullmatch(r"iPhone \d+", d["name"])]
print(phones[-1]["udid"])
')"
echo "Using simulator $udid"

xcrun simctl boot "$udid" || true
xcrun simctl bootstatus "$udid" -b
xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100
xcrun simctl install "$udid" "$app"

SIMCTL_CHILD_ZEN_DEMO_DATA=1 xcrun simctl launch "$udid" "$bundle_id"
sleep 5
xcrun simctl io "$udid" screenshot "$out/space-screen.png"
echo "Saved screenshots to $out"
