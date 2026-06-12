#!/bin/bash
# Builds Cow.app — a double-clickable macOS application bundle (with icon).
set -e
cd "$(dirname "$0")"

APP="Cow.app"

# --- 1. Build the app icon from icon_1024.png (capture it with capture-icon.sh) ---
if [ ! -f icon_1024.png ]; then
    echo "icon_1024.png missing — run ./capture-icon.sh first"; exit 1
fi

ICONSET="Cow.iconset"
rm -rf "$ICONSET"; mkdir "$ICONSET"
sips -z 16   16   icon_1024.png --out "$ICONSET/icon_16x16.png"      >/dev/null
sips -z 32   32   icon_1024.png --out "$ICONSET/icon_16x16@2x.png"   >/dev/null
sips -z 32   32   icon_1024.png --out "$ICONSET/icon_32x32.png"      >/dev/null
sips -z 64   64   icon_1024.png --out "$ICONSET/icon_32x32@2x.png"   >/dev/null
sips -z 128  128  icon_1024.png --out "$ICONSET/icon_128x128.png"    >/dev/null
sips -z 256  256  icon_1024.png --out "$ICONSET/icon_128x128@2x.png" >/dev/null
sips -z 256  256  icon_1024.png --out "$ICONSET/icon_256x256.png"    >/dev/null
sips -z 512  512  icon_1024.png --out "$ICONSET/icon_256x256@2x.png" >/dev/null
sips -z 512  512  icon_1024.png --out "$ICONSET/icon_512x512.png"    >/dev/null
cp icon_1024.png                "$ICONSET/icon_512x512@2x.png"
iconutil -c icns "$ICONSET" -o Cow.icns
rm -rf "$ICONSET"

# --- 2. Assemble the bundle ---
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc CowWidget.swift -O -o "$APP/Contents/MacOS/CowWidget"
cp Cow.icns "$APP/Contents/Resources/Cow.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>               <string>Cow</string>
    <key>CFBundleDisplayName</key>        <string>Cow</string>
    <key>CFBundleIdentifier</key>         <string>com.william.cowwidget</string>
    <key>CFBundleExecutable</key>         <string>CowWidget</string>
    <key>CFBundleIconFile</key>           <string>Cow</string>
    <key>CFBundlePackageType</key>        <string>APPL</string>
    <key>CFBundleShortVersionString</key> <string>1.0</string>
    <key>CFBundleVersion</key>            <string>1</string>
    <key>LSMinimumSystemVersion</key>     <string>11.0</string>
    <key>NSHighResolutionCapable</key>    <true/>
    <key>NSPrincipalClass</key>           <string>NSApplication</string>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP" 2>/dev/null || true
touch "$APP"
echo "Built $APP"
