// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ugalek",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.3"),

        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        
        // 🐘 Non-blocking, event-driven Swift client for PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.4"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.3.3"),
        .package(url: "https://github.com/vapor-community/markdown.git", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/nodes-vapor/slugify", from: "2.0.0"),
        .package(url: "https://github.com/vapor-community/lingo-vapor.git", from: "3.0.1")
     ],
    targets: [
        .target(name: "App", dependencies: ["Leaf", "Vapor", "FluentPostgreSQL", "Authentication", "Crypto", "SwiftMarkdown", "Slugify", "LingoVapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "FluentPostgreSQL"])
    ]
)

