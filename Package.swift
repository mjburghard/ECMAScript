// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ECMAScript",
    products: [
        .library(name: "ECMAScript", targets: ["ECMAScript"]),
    ],
    dependencies: [
        .package(name: "JavaScriptKit", url: "https://github.com/Unkaputtbar/JavaScriptKit.git", .branch("feature/webidl-support")),
    ],
    targets: [
        .target(name: "ECMAScript", dependencies: ["JavaScriptKit"])
    ]
)
