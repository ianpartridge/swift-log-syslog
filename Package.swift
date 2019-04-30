// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "swift-log-syslog",
    products: [
        .library(
            name: "LoggingSyslog",
            targets: ["LoggingSyslog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .systemLibrary(name: "CSyslog"),
        .target(
            name: "LoggingSyslog",
            dependencies: ["Logging", .target(name: "CSyslog")]),
        .testTarget(
            name: "LoggingSyslogTests",
            dependencies: ["LoggingSyslog", "Logging"]),
    ]
)
