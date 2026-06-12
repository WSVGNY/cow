#!/bin/bash
# Regenerates icon_1024.png by screenshotting the running app and pixel-upscaling
# a crop of the cow (nearest-neighbor, so it stays crisp).
set -e
cd "$(dirname "$0")"

swiftc upscale.swift -o upscale

# Fresh launch so the cow is centered and facing right.
pkill -f CowWidget 2>/dev/null || true
sleep 1
open Cow.app
sleep 1.2

read RX RY < <(python3 -c '
import Quartz
ws = Quartz.CGWindowListCopyWindowInfo(Quartz.kCGWindowListOptionAll, Quartz.kCGNullWindowID)
for w in ws:
    if w.get("kCGWindowOwnerName","") in ("Cow","CowWidget"):
        b=w["kCGWindowBounds"]; print(int(b["X"]*2),int(b["Y"]*2)); break
')

screencapture -T 0 /tmp/shot.png
# Square crop around the cow (retina px, top-left origin).
sips -c 260 260 --cropOffset $((RY+100)) $((RX+70)) /tmp/shot.png --out /tmp/cowcrop.png >/dev/null
./upscale /tmp/cowcrop.png 1024 icon_1024.png
echo "icon_1024.png updated from a live screenshot"
