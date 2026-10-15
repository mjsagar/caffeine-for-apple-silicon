import AppKit

enum IconRenderer {
    static let iconSize = NSSize(width: 18, height: 18)
    
    /// Creates the menu bar icon based on active state
    static func statusIcon(isActive: Bool) -> NSImage {
        let image = NSImage(size: iconSize, flipped: false) { rect in
            let path = NSBezierPath()
            path.lineWidth = 1.3
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            
            NSColor.black.setStroke()
            NSColor.black.setFill()
            
            // Saucer at the base
            let saucer = NSBezierPath()
            saucer.lineWidth = 1.3
            saucer.lineCapStyle = .round
            saucer.move(to: NSPoint(x: 2.2, y: 2.5))
            saucer.curve(to: NSPoint(x: 13.8, y: 2.5),
                         controlPoint1: NSPoint(x: 4.5, y: 1.2),
                         controlPoint2: NSPoint(x: 11.5, y: 1.2))
            saucer.stroke()
            
            // Cup Body coordinates
            let cupTopY: CGFloat = isActive ? 10.0 : 10.8
            let cupBottomY: CGFloat = 3.6
            let cupLeftX: CGFloat = 3.4
            let cupRightX: CGFloat = 12.6
            let cupBottomLeftX: CGFloat = 4.8
            let cupBottomRightX: CGFloat = 11.2
            
            let cup = NSBezierPath()
            cup.lineWidth = 1.3
            cup.lineCapStyle = .round
            cup.lineJoinStyle = .round
            
            cup.move(to: NSPoint(x: cupLeftX, y: cupTopY))
            cup.line(to: NSPoint(x: cupRightX, y: cupTopY))
            cup.line(to: NSPoint(x: cupBottomRightX, y: cupBottomY + 1.2))
            cup.curve(to: NSPoint(x: cupBottomLeftX, y: cupBottomY + 1.2),
                      controlPoint1: NSPoint(x: 10.6, y: cupBottomY),
                      controlPoint2: NSPoint(x: 5.4, y: cupBottomY))
            cup.close()
            
            if isActive {
                // In classic Caffeine, active cup is filled with rich coffee
                cup.fill()
            } else {
                // Inactive cup is empty
                cup.stroke()
            }
            
            // Cup Handle
            let handle = NSBezierPath()
            handle.lineWidth = 1.3
            handle.lineCapStyle = .round
            handle.move(to: NSPoint(x: cupRightX - 0.4, y: cupTopY - 1.4))
            handle.curve(to: NSPoint(x: cupRightX - 0.4, y: cupBottomY + 1.6),
                         controlPoint1: NSPoint(x: 16.4, y: cupTopY - 0.4),
                         controlPoint2: NSPoint(x: 16.4, y: cupBottomY + 0.6))
            handle.stroke()
            
            // Steam curls rising from the cup (only when active!)
            if isActive {
                let steam1 = NSBezierPath()
                steam1.lineWidth = 1.2
                steam1.lineCapStyle = .round
                steam1.move(to: NSPoint(x: 5.8, y: cupTopY + 1.2))
                steam1.curve(to: NSPoint(x: 5.5, y: cupTopY + 5.6),
                             controlPoint1: NSPoint(x: 7.2, y: cupTopY + 2.8),
                             controlPoint2: NSPoint(x: 4.4, y: cupTopY + 4.0))
                steam1.stroke()
                
                let steam2 = NSBezierPath()
                steam2.lineWidth = 1.2
                steam2.lineCapStyle = .round
                steam2.move(to: NSPoint(x: 9.8, y: cupTopY + 1.2))
                steam2.curve(to: NSPoint(x: 9.6, y: cupTopY + 6.0),
                             controlPoint1: NSPoint(x: 11.2, y: cupTopY + 2.8),
                             controlPoint2: NSPoint(x: 8.5, y: cupTopY + 4.4))
                steam2.stroke()
            }
            
            return true
        }
        
        image.isTemplate = true
        return image
    }
}
