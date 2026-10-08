import AppKit

let output = CommandLine.arguments[1]
try FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true)
for size in [16, 32, 64, 128, 256, 512, 1024] {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let scale = CGFloat(size) / 1024
    let transform = NSAffineTransform()
    transform.scale(by: scale)
    transform.concat()
    NSColor(calibratedRed: 0.10, green: 0.13, blue: 0.17, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 48, y: 48, width: 928, height: 928), xRadius: 205, yRadius: 205).fill()
    NSColor(calibratedRed: 1, green: 0.73, blue: 0.35, alpha: 1).setStroke()
    let handle = NSBezierPath(ovalIn: NSRect(x: 624, y: 360, width: 164, height: 192))
    handle.lineWidth = 46
    handle.stroke()
    NSColor(calibratedRed: 1, green: 0.73, blue: 0.35, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 264, y: 292, width: 410, height: 300), xRadius: 72, yRadius: 72).fill()
    let saucer = NSBezierPath()
    saucer.move(to: NSPoint(x: 242, y: 238))
    saucer.line(to: NSPoint(x: 712, y: 238))
    saucer.lineWidth = 34
    saucer.lineCapStyle = .round
    saucer.stroke()
    for x in [380, 500, 620] {
        let steam = NSBezierPath()
        steam.move(to: NSPoint(x: x, y: 660))
        steam.curve(to: NSPoint(x: x, y: 810), controlPoint1: NSPoint(x: x - 60, y: 705), controlPoint2: NSPoint(x: x + 55, y: 765))
        steam.lineWidth = 30
        steam.lineCapStyle = .round
        steam.stroke()
    }
    NSGraphicsContext.restoreGraphicsState()
    let png = bitmap.representation(using: .png, properties: [:])!
    try png.write(to: URL(fileURLWithPath: "\(output)/icon_\(size).png"))
}
