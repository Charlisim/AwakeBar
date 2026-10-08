// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "AwakeBar", platforms: [.macOS(.v14)], products: [.executable(name: "AwakeBar", targets: ["AwakeBar"])], targets: [.executableTarget(name: "AwakeBar")])
