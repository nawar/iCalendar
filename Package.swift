// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "iCalendar",
    products: [
        .library( name: "iCalendar", targets: ["iCalendar"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "iCalendar",
            dependencies: []),
        .testTarget(
            name: "iCalendarTests",
            dependencies: []),
    ]
)
