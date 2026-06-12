import AppKit

// Upscales an image to a square using nearest-neighbor (keeps pixels crisp).
// usage: upscale <input.png> <outSize> <output.png>
let a = CommandLine.arguments
let src = NSImage(contentsOfFile: a[1])!
let outSize = Int(a[2]) ?? 1024
var pr = NSRect(origin: .zero, size: src.size)
let cg = src.cgImage(forProposedRect: &pr, context: nil, hints: nil)!

let out = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: outSize, pixelsHigh: outSize,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
let g = NSGraphicsContext(bitmapImageRep: out)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = g
g.cgContext.interpolationQuality = .none
g.cgContext.draw(cg, in: CGRect(x: 0, y: 0, width: CGFloat(outSize), height: CGFloat(outSize)))
NSGraphicsContext.restoreGraphicsState()
try! out.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: a[3]))
print("wrote \(a[3])")
