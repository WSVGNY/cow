import AppKit

// MARK: - Palette

private func px(_ i: UInt8, alpha: CGFloat = 1) -> NSColor {
    let c: NSColor
    switch i {
    case 1:  c = NSColor(red: 0.13, green: 0.15, blue: 0.16, alpha: 1)  // black spot
    case 2:  c = NSColor(red: 0.94, green: 0.94, blue: 0.95, alpha: 1)  // white body
    case 3:  c = NSColor(red: 0.97, green: 0.78, blue: 0.85, alpha: 1)  // pink udder
    case 4:  c = NSColor(red: 0.21, green: 0.23, blue: 0.24, alpha: 1)  // hoof dark
    case 5:  c = NSColor(red: 0.92, green: 0.18, blue: 0.28, alpha: 1)  // red / heart
    case 6:  c = NSColor(red: 0.99, green: 0.99, blue: 1.00, alpha: 0.95) // cloud white
    case 7:  c = NSColor(red: 0.22, green: 0.56, blue: 0.16, alpha: 1)  // dark green
    case 8:  c = NSColor(red: 0.72, green: 0.72, blue: 0.74, alpha: 1)  // gray (legs/muzzle)
    case 9:  c = NSColor(red: 0.45, green: 0.31, blue: 0.18, alpha: 1)  // tree trunk brown
    case 10: c = NSColor(red: 0.17, green: 0.43, blue: 0.19, alpha: 1)  // tree foliage dark
    case 11: c = NSColor(red: 0.27, green: 0.57, blue: 0.28, alpha: 1)  // tree foliage light
    default: return .clear
    }
    return alpha < 1 ? c.withAlphaComponent(alpha) : c
}

// MARK: - Cow Sprite (built from rectangle regions, faces right)

private func buildCow() -> [[UInt8]] {
    let cols = 20, rows = 12
    var g = Array(repeating: Array(repeating: UInt8(0), count: cols), count: rows)
    func span(_ c: UInt8, _ y: Int, _ x0: Int, _ x1: Int) {   // inclusive horizontal run
        guard y >= 0 && y < rows else { return }
        for x in x0...x1 where x >= 0 && x < cols { g[y][x] = c }
    }
    func rect(_ c: UInt8, _ x: Int, _ y: Int, _ w: Int, _ h: Int) {
        for yy in y..<(y + h) where yy >= 0 && yy < rows {
            for xx in x..<(x + w) where xx >= 0 && xx < cols { g[yy][xx] = c }
        }
    }
    // --- White body: curved back & belly, mass ends at the front legs ---
    span(2, 1, 4, 12)        // back (rounded rump on left, rises toward shoulder)
    span(2, 2, 2, 13)
    span(2, 3, 2, 13)
    span(2, 4, 2, 13)
    span(2, 5, 2, 13)
    span(2, 6, 2, 13)        // flatter underside so legs reach the corners
    span(2, 7, 2, 13)
    // --- Neck + head rising from the chest (right side) ---
    span(2, 0, 13, 15)
    span(2, 1, 12, 16)
    span(2, 2, 13, 16)
    span(2, 3, 14, 16)
    // --- Leg tops (white) connect to belly ---
    for col in [2, 4, 11, 13] { span(2, 8, col, col) }
    // --- Head detail ---
    span(1, 0, 13, 14)       // poll (black top patch)
    span(1, 3, 14, 15)       // jaw / cheek patch
    rect(8, 16, 2, 2, 2)     // gray muzzle (cols 16-17, rows 2-3)
    // --- Spots ---
    span(1, 2, 2, 4); span(1, 3, 2, 3); span(1, 4, 2, 3)               // rump
    span(1, 2, 10, 12); span(1, 3, 9, 12); span(1, 4, 9, 12); span(1, 5, 9, 11)  // shoulder
    span(1, 4, 5, 7); span(1, 5, 5, 8); span(1, 6, 6, 8)              // belly center
    // --- Udder ---
    span(3, 8, 7, 9)         // pink
    span(8, 9, 7, 8)         // gray teats
    // --- Legs (gray shanks + hooves): back legs at the rump, front legs at the chest ---
    for col in [2, 4, 11, 13] {
        rect(8, col, 9, 1, 2)   // gray shank (rows 9-10)
        rect(4, col, 11, 1, 1)  // hoof
    }
    return g
}

private let sprCow = buildCow()
private let sprCowL = sprCow.map { Array($0.reversed()) }   // mirrored: faces left

// MARK: - Other Sprites  (0 = transparent)

private let sprHeart: [[UInt8]] = [
    [0,5,5,0,5,5,0],
    [5,5,5,5,5,5,5],
    [5,5,5,5,5,5,5],
    [0,5,5,5,5,5,0],
    [0,0,5,5,5,0,0],
    [0,0,0,5,0,0,0],
]

private let sprCloudA: [[UInt8]] = [
    [0,0,6,6,6,6,0,0,0],
    [0,6,6,6,6,6,6,6,0],
    [6,6,6,6,6,6,6,6,6],
    [6,6,6,6,6,6,6,6,0],
]

private let sprCloudB: [[UInt8]] = [
    [0,6,6,6,0],
    [6,6,6,6,6],
    [6,6,6,6,6],
    [0,6,6,6,0],
]

private let sprCloudC: [[UInt8]] = [
    [0,0,6,6,6,6,6,0,0,0,0],
    [0,6,6,6,6,6,6,6,6,0,0],
    [6,6,6,6,6,6,6,6,6,6,6],
    [0,6,6,6,6,6,6,6,6,6,0],
]

private let sprTree: [[UInt8]] = [
    [ 0, 0, 0,10,10,10, 0, 0, 0],
    [ 0, 0,10,10,11,10,10, 0, 0],
    [ 0,10,10,11,11,10,10,10, 0],
    [10,10,11,11,10,10,10,10,10],
    [10,10,10,10,10,10,10,10,10],
    [10,11,10,10,10,10,10,10,10],
    [ 0,10,10,10,10,10,10,10, 0],
    [ 0, 0,10,10,10,10,10, 0, 0],
    [ 0, 0, 0,10,10,10, 0, 0, 0],
    [ 0, 0, 0, 0, 9, 9, 0, 0, 0],
    [ 0, 0, 0, 0, 9, 9, 0, 0, 0],
    [ 0, 0, 0, 0, 9, 9, 0, 0, 0],
    [ 0, 0, 0, 0, 9, 9, 0, 0, 0],
    [ 0, 0, 0, 0, 9, 9, 0, 0, 0],
]

// MARK: - Draw Helper

private func drawSprite(
    _ pixels: [[UInt8]],
    at origin: NSPoint,
    scale s: CGFloat,
    alpha: CGFloat = 1
) {
    for (row, rowData) in pixels.enumerated() {
        for (col, ci) in rowData.enumerated() {
            guard ci != 0 else { continue }
            px(ci, alpha: alpha).setFill()
            NSBezierPath(rect: NSRect(
                x: origin.x + CGFloat(col) * s,
                y: origin.y - CGFloat(row + 1) * s,
                width: s, height: s
            )).fill()
        }
    }
}

// MARK: - Particles

struct HeartParticle {
    var x: CGFloat
    var y: CGFloat
    let vy: CGFloat
    var age: CGFloat = 0
    static let maxAge: CGFloat = 70

    mutating func update() { y += vy; age += 1 }
    var alpha: CGFloat {
        let t = age / Self.maxAge
        return t < 0.6 ? 1.0 : max(0, (1.0 - t) / 0.4)
    }
    var dead: Bool { age >= Self.maxAge }
}

struct Cloud {
    var x: CGFloat
    let y: CGFloat
    let speed: CGFloat
    let sprite: [[UInt8]]
    let scale: CGFloat
}

// Deterministic RNG so the grass texture is generated once and stays put.
struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed != 0 ? seed : 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

struct GrassBlade { let x: CGFloat; let y: CGFloat; let h: CGFloat; let dark: Bool }
struct Flower { let x: CGFloat; let y: CGFloat; let kind: Int }

// MARK: - Cow View

class CowView: NSView {

    // Layout constants (zoomed out: smaller cow, more scene)
    private let S: CGFloat = 6          // pixel scale
    private let grassY: CGFloat = 52    // AppKit y of the sky/grass boundary (horizon)
    private let grassPx: CGFloat = 4    // chunky pixel size for the grass (8-bit grid)
    private let cowFootY: CGFloat = 28  // where the cow's hooves rest (below horizon, for perspective)
    private var cowY: CGFloat { cowFootY + CGFloat(sprCow.count) * S }   // top of cow sprite

    // State
    private var hearts: [HeartParticle] = []
    private var clouds: [Cloud] = []
    private var cloudCountdown = 0
    private var jumpY: CGFloat = 0       // current hop height
    private var jumpVy: CGFloat = 0      // hop velocity
    private var pendingJumps = 0         // queued hops from stacked clicks
    private let gravity: CGFloat = 0.34
    private var blades: [GrassBlade] = []
    private var flowers: [Flower] = []
    private var windPhase: CGFloat = 0

    // Wandering
    private var cowPosX: CGFloat = 40    // current left edge of the cow sprite
    private var cowVx: CGFloat = 0       // 0 = grazing, else walking
    private var facingLeft = false
    private var walkPhase: CGFloat = 0
    private var actionCountdown = 60
    private let walkSpeed: CGFloat = 0.45
    private var cowW: CGFloat { CGFloat(sprCow[0].count) * S }

    override init(frame: NSRect) {
        super.init(frame: frame)
        seedClouds()
        seedGrass(width: frame.width)
        Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func seedGrass(width W: CGFloat) {
        var rng = SeededRNG(seed: 0xC0FFEE42)
        let P = grassPx
        // An even field of blocky blades on the pixel grid; nearer (lower y) blades are taller.
        var col: CGFloat = 0
        while col < W {
            let yUnit = Int.random(in: 0...max(1, Int((grassY - P) / P) - 1), using: &rng)
            let y = CGFloat(yUnit) * P                       // base snapped to the grid
            let persp = 1 - y / grassY                       // 1 near viewer, 0 at horizon
            let pixTall = 1 + Int(persp * 2) + Int.random(in: 0...1, using: &rng)   // short clumps
            blades.append(GrassBlade(x: col, y: y, h: CGFloat(pixTall) * P,
                                     dark: Int.random(in: 0...2, using: &rng) == 0))
            col += P * 6                                      // space between tufts (sparser)
        }
        for _ in 0..<2 {
            let fx = CGFloat(Int.random(in: 1...Int(W / P - 2), using: &rng)) * P
            let fy = CGFloat(Int.random(in: 1...Int(cowFootY / P), using: &rng)) * P
            flowers.append(Flower(x: fx, y: fy, kind: Int.random(in: 0...1, using: &rng)))
        }
    }

    // MARK: Animation tick (30fps)

    private func tick() {
        // Wind (drives the grass sway)
        windPhase += 0.12

        // Hearts
        hearts = hearts.compactMap { var h = $0; h.update(); return h.dead ? nil : h }

        // Hop physics
        if jumpVy != 0 || jumpY > 0 {
            jumpY += jumpVy
            jumpVy -= gravity
            if jumpY <= 0 { jumpY = 0; jumpVy = 0 }
        }
        // Once grounded, launch the next queued hop (stacked clicks bounce in sequence)
        if jumpY == 0 && jumpVy == 0 && pendingJumps > 0 {
            pendingJumps -= 1
            jumpVy = 3.6
        }

        // Wander: alternate between grazing and ambling in a random direction
        if jumpY == 0 && pendingJumps == 0 {
            actionCountdown -= 1
            if actionCountdown <= 0 {
                if cowVx != 0 {                       // was walking -> graze
                    cowVx = 0
                    actionCountdown = Int.random(in: 60...150)
                } else {                              // was grazing -> walk
                    facingLeft = Bool.random()
                    cowVx = (facingLeft ? -1 : 1) * walkSpeed
                    actionCountdown = Int.random(in: 90...210)
                }
            }
        }
        if cowVx != 0 {
            cowPosX += cowVx
            walkPhase += 0.35
            let minX: CGFloat = 6, maxX = bounds.width - cowW - 6
            if cowPosX <= minX { cowPosX = minX; cowVx = walkSpeed;  facingLeft = false }
            if cowPosX >= maxX { cowPosX = maxX; cowVx = -walkSpeed; facingLeft = true }
        }

        // Clouds drift with the wind (left -> right) and recycle
        for i in clouds.indices { clouds[i].x += clouds[i].speed }
        clouds.removeAll { $0.x > bounds.width + 4 }
        cloudCountdown -= 1
        if cloudCountdown <= 0 && clouds.count < 4 {
            spawnCloud(fromLeft: true)
            cloudCountdown = Int.random(in: 120...300)   // ~4-10s
        }

        needsDisplay = true
    }

    // MARK: Clouds

    private func randomCloudSprite() -> ([[UInt8]], CGFloat) {
        switch Int.random(in: 0...2) {
        case 0:  return (sprCloudA, CGFloat.random(in: 3...4))
        case 1:  return (sprCloudB, CGFloat.random(in: 3...5))
        default: return (sprCloudC, CGFloat.random(in: 3...4))
        }
    }

    private func spawnCloud(fromLeft: Bool) {
        let (sprite, scale) = randomCloudSprite()
        let h = bounds.height
        let y = CGFloat.random(in: (grassY + 55)...(h - 8))
        let w = CGFloat(sprite[0].count) * scale
        let x = fromLeft ? -w : CGFloat.random(in: 0...(bounds.width - w))
        clouds.append(Cloud(x: x, y: y, speed: CGFloat.random(in: 0.10...0.28),
                            sprite: sprite, scale: scale))
    }

    private func seedClouds() {
        for _ in 0..<2 { spawnCloud(fromLeft: false) }
        cloudCountdown = Int.random(in: 90...200)
    }

    // MARK: Drawing

    override func draw(_ dirtyRect: NSRect) {
        let ctx = NSGraphicsContext.current
        ctx?.shouldAntialias = true                                   // smooth rounded corners
        NSBezierPath(roundedRect: bounds, xRadius: 14, yRadius: 14).addClip()
        ctx?.shouldAntialias = false                                  // crisp, seamless pixels
        drawScene()
    }

    private func drawScene() {
        let W = bounds.width, H = bounds.height

        // Sky
        NSColor(red: 0.44, green: 0.74, blue: 0.94, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: 0, y: grassY, width: W, height: H - grassY)).fill()

        // Drifting clouds
        for c in clouds {
            drawSprite(c.sprite, at: NSPoint(x: c.x, y: c.y), scale: c.scale)
        }

        // Tall trees on the horizon (background; trunk base sits on the grass line)
        drawSprite(sprTree, at: NSPoint(x: -10,        y: grassY + 14 * 5), scale: 5)
        drawSprite(sprTree, at: NSPoint(x: W * 0.40 - 8, y: grassY + 14 * 7), scale: 7)
        drawSprite(sprTree, at: NSPoint(x: W - 42,     y: grassY + 14 * 5), scale: 5)

        // Grass field + horizon line
        NSColor(red: 0.36, green: 0.72, blue: 0.27, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: W, height: grassY)).fill()
        NSColor(red: 0.24, green: 0.54, blue: 0.16, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: 0, y: grassY - 2, width: W, height: 4)).fill()

        // Post-and-rail fence along the horizon (behind the cow)
        drawFence(width: W)

        // Background grass — blades farther than the cow
        for b in blades where b.y >= cowFootY { drawBlade(b) }
        // Wildflowers (behind the cow, near the horizon)
        for f in flowers {
            drawFlower(at: NSPoint(x: f.x, y: f.y), kind: f.kind,
                       sway: sin(windPhase + f.x * 0.05) * 2.0 + 1.0)
        }

        // Shadow at the cow's hooves (shrinks as it hops up) — smooth oval
        let bob = cowVx != 0 ? abs(sin(walkPhase)) * 1.5 : 0
        let shadowW = max(40, cowW * 0.7 - jumpY * 1.4)
        NSGraphicsContext.current?.shouldAntialias = true
        NSColor(red: 0.20, green: 0.45, blue: 0.13, alpha: 0.28).setFill()
        NSBezierPath(ovalIn: NSRect(
            x: cowPosX + cowW / 2 - shadowW / 2, y: cowFootY - 5,
            width: shadowW, height: 9
        )).fill()
        NSGraphicsContext.current?.shouldAntialias = false

        // Cow — lifted by the hop, with a gentle bounce while walking, facing its heading
        drawSprite(facingLeft ? sprCowL : sprCow,
                   at: NSPoint(x: cowPosX, y: cowY + jumpY + bob), scale: S)

        // Foreground grass — nearer, taller blades drawn in front of the cow
        for b in blades where b.y < cowFootY { drawBlade(b) }

        // Floating hearts
        for heart in hearts {
            drawSprite(sprHeart, at: NSPoint(x: heart.x, y: heart.y), scale: 3, alpha: heart.alpha)
        }
    }

    // A grass tuft: a fan of three short blades (sides splay out, center is tallest).
    private func drawBlade(_ b: GrassBlade) {
        let P = grassPx
        let lean = (sin(windPhase + b.x * 0.05) * 1.3 + 0.3).rounded()   // chunky, discrete wind
        let n = max(1, Int((b.h / P).rounded()))
        drawGrassColumn(x: b.x,         baseY: b.y, n: n,     topLean: lean - 1, dark: b.dark)
        drawGrassColumn(x: b.x + P,     baseY: b.y, n: n + 1, topLean: lean,     dark: b.dark)
        drawGrassColumn(x: b.x + 2 * P, baseY: b.y, n: n,     topLean: lean + 1, dark: b.dark)
    }

    private func drawGrassColumn(x: CGFloat, baseY: CGFloat, n: Int, topLean: CGFloat, dark: Bool) {
        let P = grassPx
        let body = dark ? NSColor(red: 0.24, green: 0.50, blue: 0.16, alpha: 1)
                        : NSColor(red: 0.30, green: 0.60, blue: 0.22, alpha: 1)
        let tip  = NSColor(red: 0.42, green: 0.73, blue: 0.31, alpha: 1)   // lighter 8-bit tip
        for r in 0..<n {
            let t = n <= 1 ? 0 : CGFloat(r) / CGFloat(n - 1)
            let off = (topLean * t).rounded()                              // discrete pixel offset
            (r == n - 1 ? tip : body).setFill()
            NSBezierPath(rect: NSRect(x: x + off * P, y: baseY + CGFloat(r) * P,
                                      width: P, height: P)).fill()
        }
    }

    private func drawFlower(at p: NSPoint, kind: Int, sway: CGFloat = 0) {
        let q: CGFloat = 2                                   // flower pixel size
        let off = (sway / q).rounded() * q                  // lean snapped to the grid
        let head = NSPoint(x: p.x + off, y: p.y)
        // Stem — a little column of pixels (base straight, top leans)
        NSColor(red: 0.24, green: 0.50, blue: 0.16, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: p.x, y: p.y - 4, width: q, height: 4)).fill()
        NSBezierPath(rect: NSRect(x: head.x, y: p.y, width: q, height: q)).fill()
        // Petals (blocky)
        let petal = kind == 0 ? NSColor(red: 0.98, green: 0.98, blue: 1.00, alpha: 1)
                              : NSColor(red: 0.96, green: 0.62, blue: 0.76, alpha: 1)
        petal.setFill()
        for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
            NSBezierPath(rect: NSRect(x: head.x + CGFloat(dx) * q, y: head.y + CGFloat(dy) * q,
                                      width: q, height: q)).fill()
        }
        // Center
        NSColor(red: 0.99, green: 0.86, blue: 0.32, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: head.x, y: head.y, width: q, height: q)).fill()
    }

    private func drawFence(width W: CGFloat) {
        let rail = NSColor(red: 0.62, green: 0.45, blue: 0.28, alpha: 1)
        let post = NSColor(red: 0.48, green: 0.33, blue: 0.19, alpha: 1)
        // Two thick horizontal rails
        rail.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: grassY + 24, width: W, height: 5)).fill()
        NSBezierPath(rect: NSRect(x: 0, y: grassY + 11, width: W, height: 5)).fill()
        // Tall vertical posts
        post.setFill()
        var x: CGFloat = 10
        while x < W {
            NSBezierPath(rect: NSRect(x: x, y: grassY, width: 6, height: 36)).fill()
            x += 40
        }
    }

    // Clickable region covering the cow at its current position.
    private var cowRect: NSRect {
        NSRect(x: cowPosX, y: grassY, width: cowW, height: CGFloat(sprCow.count) * S)
    }

    // MARK: Interaction

    override func mouseDown(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        if cowRect.contains(loc) {
            feedCow()
        } else {
            // Hand off to AppKit's native window drag — smooth, server-side.
            window?.performDrag(with: event)
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    override var acceptsFirstResponder: Bool { true }

    // MARK: Feed

    func feed() { feedCow() }   // public entry for menu commands

    private func feedCow() {
        // Queue a hop; stacked clicks bounce one after another (capped so spam ends)
        pendingJumps = min(pendingJumps + 1, 8)

        // Stop to eat, then resume wandering shortly after
        cowVx = 0
        actionCountdown = max(actionCountdown, 75)

        // A couple of hearts at random spots around the cow
        for _ in 0..<2 {
            hearts.append(HeartParticle(
                x: cowPosX + CGFloat.random(in: -6...(cowW + 6)),
                y: cowY + CGFloat.random(in: -28...10),
                vy: CGFloat.random(in: 0.6...1.1)
            ))
        }
    }
}

// MARK: - App Entry

let app = NSApplication.shared
app.setActivationPolicy(.regular)   // Dock icon + top menu bar

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var cowView: CowView!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ note: Notification) {
        let size = NSSize(width: 200, height: 190)
        window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.title = "Cow"
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.isMovableByWindowBackground = false   // we drag via performDrag
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.level = .normal
        window.isReleasedWhenClosed = false

        let view = CowView(frame: NSRect(origin: .zero, size: size))
        window.contentView = view
        cowView = view

        if let screen = NSScreen.main {
            window.setFrameOrigin(NSPoint(
                x: screen.visibleFrame.maxX - size.width - 20,
                y: screen.visibleFrame.maxY - size.height - 20
            ))
        }
        window.makeKeyAndOrderFront(nil)

        setupMainMenu()
        setupStatusItem()
        NSApp.activate(ignoringOtherApps: true)
    }

    // Top menu bar (app menu with Feed / Show / Quit).
    private func setupMainMenu() {
        let mainMenu = NSMenu()
        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let m = NSMenu()
        m.addItem(withTitle: "About Cow",
                  action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        m.addItem(.separator())
        let feed = NSMenuItem(title: "Feed the Cow", action: #selector(feedAction), keyEquivalent: "f")
        feed.target = self; m.addItem(feed)
        let show = NSMenuItem(title: "Show Cow", action: #selector(showWindow), keyEquivalent: "0")
        show.target = self; m.addItem(show)
        m.addItem(.separator())
        m.addItem(withTitle: "Quit Cow", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = m
        NSApp.mainMenu = mainMenu
    }

    // Menu bar (status bar) item with a little cow.
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🐄"
        let menu = NSMenu()
        let feed = NSMenuItem(title: "Feed the Cow", action: #selector(feedAction), keyEquivalent: "")
        feed.target = self; menu.addItem(feed)
        let show = NSMenuItem(title: "Show Cow", action: #selector(showWindow), keyEquivalent: "")
        show.target = self; menu.addItem(show)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        statusItem.menu = menu
    }

    @objc func feedAction() { cowView?.feed() }
    @objc func showWindow() {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // Clicking the Dock icon (with no window open) brings the cow back.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { window.makeKeyAndOrderFront(nil) }
        return true
    }
    // Closing the window just hides it; the app keeps living in the Dock / menu bar.
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool { false }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
