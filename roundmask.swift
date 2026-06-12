import AppKit

// Masks an image to a rounded rectangle (corners -> transparent), optionally
// cropping to a top-left WxH first.
// usage: roundmask <in> <out> <radius> [cropW cropH]
let a = CommandLine.arguments
let src = NSImage(contentsOfFile: a[1])!
var pr = NSRect(origin: .zero, size: src.size)
let cg = src.cgImage(forProposedRect: &pr, context: nil, hints: nil)!
let fullW = cg.width, fullH = cg.height
let radius = CGFloat(Double(a[3])!)
let outW = a.count > 4 ? Int(a[4])! : fullW
let outH = a.count > 4 ? Int(a[5])! : fullH

let ctx = CGContext(data: nil, width: outW, height: outH, bitsPerComponent: 8,
                    bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.interpolationQuality = .none
// Clip to a rounded rect, then paint the image top-left-aligned (extra right/bottom clipped).
ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: outW, height: outH),
                   cornerWidth: radius, cornerHeight: radius, transform: nil))
ctx.clip()
ctx.draw(cg, in: CGRect(x: 0, y: CGFloat(outH - fullH), width: CGFloat(fullW), height: CGFloat(fullH)))

let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: a[2]))
print("wrote \(a[2])  (\(outW)x\(outH), r\(Int(radius)))")
