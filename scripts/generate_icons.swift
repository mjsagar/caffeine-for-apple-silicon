import AppKit

func createIconImage(size: CGFloat) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        img.unlockFocus()
        return img
    }
    
    // Squircle container
    let margin = size * 0.1
    let cornerRadius = size * 0.22
    let bgRect = NSRect(x: margin, y: margin, width: size - 2 * margin, height: size - 2 * margin)
    let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    // Rich espresso gradient
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(calibratedRed: 0.16, green: 0.12, blue: 0.10, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.34, green: 0.22, blue: 0.16, alpha: 1.0).cgColor
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
    
    ctx.saveGState()
    bgPath.addClip()
    ctx.drawLinearGradient(gradient,
                           start: CGPoint(x: 0, y: size),
                           end: CGPoint(x: 0, y: 0),
                           options: [])
    ctx.restoreGState()
    
    // Inner border highlight
    NSColor(white: 1.0, alpha: 0.18).setStroke()
    bgPath.lineWidth = max(1.0, size * 0.015)
    bgPath.stroke()
    
    // Scale factor for 100-based coordinate canvas
    let scale = size / 100.0
    ctx.saveGState()
    ctx.translateBy(x: size * 0.08, y: size * 0.04)
    
    // Saucer
    let saucer = NSBezierPath()
    saucer.lineWidth = 3.5 * scale
    saucer.lineCapStyle = .round
    saucer.move(to: NSPoint(x: 20 * scale, y: 28 * scale))
    saucer.curve(to: NSPoint(x: 68 * scale, y: 28 * scale),
                 controlPoint1: NSPoint(x: 30 * scale, y: 21 * scale),
                 controlPoint2: NSPoint(x: 58 * scale, y: 21 * scale))
    NSColor(calibratedRed: 0.95, green: 0.75, blue: 0.45, alpha: 0.85).setStroke()
    saucer.stroke()
    
    // Cup Body
    let cupPath = NSBezierPath()
    cupPath.lineWidth = 3.5 * scale
    cupPath.lineCapStyle = .round
    cupPath.lineJoinStyle = .round
    cupPath.move(to: NSPoint(x: 24 * scale, y: 58 * scale))
    cupPath.line(to: NSPoint(x: 64 * scale, y: 58 * scale))
    cupPath.line(to: NSPoint(x: 58 * scale, y: 34 * scale))
    cupPath.curve(to: NSPoint(x: 30 * scale, y: 34 * scale),
                  controlPoint1: NSPoint(x: 56 * scale, y: 27 * scale),
                  controlPoint2: NSPoint(x: 32 * scale, y: 27 * scale))
    cupPath.close()
    
    // Warm caramel fill
    NSColor(calibratedRed: 0.98, green: 0.82, blue: 0.55, alpha: 1.0).setFill()
    cupPath.fill()
    NSColor(calibratedRed: 1.0, green: 0.96, blue: 0.90, alpha: 0.95).setStroke()
    cupPath.stroke()
    
    // Handle
    let handle = NSBezierPath()
    handle.lineWidth = 3.5 * scale
    handle.lineCapStyle = .round
    handle.move(to: NSPoint(x: 62 * scale, y: 52 * scale))
    handle.curve(to: NSPoint(x: 59 * scale, y: 36 * scale),
                 controlPoint1: NSPoint(x: 78 * scale, y: 52 * scale),
                 controlPoint2: NSPoint(x: 78 * scale, y: 36 * scale))
    NSColor(calibratedRed: 0.98, green: 0.82, blue: 0.55, alpha: 1.0).setStroke()
    handle.stroke()
    
    // Steam trails
    let steam1 = NSBezierPath()
    steam1.lineWidth = 3.0 * scale
    steam1.lineCapStyle = .round
    steam1.move(to: NSPoint(x: 35 * scale, y: 64 * scale))
    steam1.curve(to: NSPoint(x: 34 * scale, y: 80 * scale),
                 controlPoint1: NSPoint(x: 41 * scale, y: 69 * scale),
                 controlPoint2: NSPoint(x: 29 * scale, y: 74 * scale))
    NSColor(calibratedRed: 1.0, green: 0.92, blue: 0.75, alpha: 0.8).setStroke()
    steam1.stroke()
    
    let steam2 = NSBezierPath()
    steam2.lineWidth = 3.0 * scale
    steam2.lineCapStyle = .round
    steam2.move(to: NSPoint(x: 51 * scale, y: 64 * scale))
    steam2.curve(to: NSPoint(x: 50 * scale, y: 82 * scale),
                 controlPoint1: NSPoint(x: 58 * scale, y: 70 * scale),
                 controlPoint2: NSPoint(x: 44 * scale, y: 76 * scale))
    NSColor(calibratedRed: 1.0, green: 0.92, blue: 0.75, alpha: 0.8).setStroke()
    steam2.stroke()
    
    ctx.restoreGState()
    
    img.unlockFocus()
    return img
}

@main
struct IconGen {
    static func main() {
        let fileManager = FileManager.default
        let currentDir = fileManager.currentDirectoryPath
        let iconsetDir = "\(currentDir)/build/Caffeine.iconset"
        let outputIcns = "\(currentDir)/Resources/AppIcon.icns"
        
        try? fileManager.createDirectory(atPath: "\(currentDir)/build", withIntermediateDirectories: true)
        try? fileManager.createDirectory(atPath: "\(currentDir)/Resources", withIntermediateDirectories: true)
        try? fileManager.removeItem(atPath: iconsetDir)
        try? fileManager.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)
        
        let sizes: [(String, CGFloat)] = [
            ("icon_16x16.png", 16),
            ("icon_16x16@2x.png", 32),
            ("icon_32x32.png", 32),
            ("icon_32x32@2x.png", 64),
            ("icon_128x128.png", 128),
            ("icon_128x128@2x.png", 256),
            ("icon_256x256.png", 256),
            ("icon_256x256@2x.png", 512),
            ("icon_512x512.png", 512),
            ("icon_512x512@2x.png", 1024)
        ]
        
        for (filename, size) in sizes {
            let img = createIconImage(size: size)
            guard let tiffData = img.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmap.representation(using: .png, properties: [:]) else {
                continue
            }
            let url = URL(fileURLWithPath: "\(iconsetDir)/\(filename)")
            try? pngData.write(to: url)
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
        process.arguments = ["-c", "icns", iconsetDir, "-o", outputIcns]
        try? process.run()
        process.waitUntilExit()
        
        print("Generated \(outputIcns)")
    }
}
