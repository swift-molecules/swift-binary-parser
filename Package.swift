// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-binary-parser",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Binary Parser",
            targets: ["Binary Parser"]
        ),
        .library(
            name: "Binary Parseable",
            targets: ["Binary Parseable"]
        ),
        .library(
            name: "Binary Input",
            targets: ["Binary Input"]
        ),
        .library(
            name: "Binary Machine",
            targets: ["Binary Machine"]
        ),
        .library(
            name: "Binary Borrowed",
            targets: ["Binary Borrowed"]
        ),
        .library(
            name: "Binary Parse",
            targets: ["Binary Parse"]
        ),
        .library(
            name: "Binary Integer",
            targets: ["Binary Integer"]
        ),
        .library(
            name: "Binary Parser Test Support",
            targets: ["Binary Parser Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-parser.git",
            branch: "main"
        ),

        .package(
            url: "https://github.com/swift-molecules/swift-binary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary-leb128.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-machine.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-vector.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-byte.git",
            branch: "main"
        ),

        .package(
            url: "https://github.com/swift-molecules/swift-byte-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-span.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-linear.git",
            branch: "main"
        ),

        .package(
            url: "https://github.com/swift-molecules/swift-ownership-shared.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Binary Input",
            dependencies: [

                .product(name: "Binary", package: "swift-binary"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Byte Parser", package: "swift-byte-parser"),
            ]
        ),

        .target(
            name: "Binary Machine",
            dependencies: [
                "Binary Input",
                .product(name: "Byte Parser", package: "swift-byte-parser"),
                .product(name: "Machine", package: "swift-machine"),
                .product(name: "Vector", package: "swift-vector"),
                .product(
                    name: "Byte Standard Library Integration",
                    package: "swift-byte"
                ),
                .product(
                    name: "Binary LEB128 Decode",
                    package: "swift-binary-leb128"
                ),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear"
                ),
                .product(
                    name: "Buffer Linear",
                    package: "swift-buffer-linear"
                ),
                .product(
                    name: "Ownership Shared Primitive",
                    package: "swift-ownership-shared"
                ),
            ]
        ),
        .target(
            name: "Binary Borrowed",
            dependencies: [
                "Binary Machine",
                .product(name: "Byte Parser", package: "swift-byte-parser"),
                .product(name: "Vector Primitive", package: "swift-vector"),
                .product(
                    name: "Byte Standard Library Integration",
                    package: "swift-byte"
                ),
                .product(
                    name: "Binary LEB128 Decode",
                    package: "swift-binary-leb128"
                ),

                .product(name: "Span Protocol", package: "swift-span"),
            ]
        ),

        .target(
            name: "Binary Parse",
            dependencies: [
                "Binary Input",
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear"
                ),
                .product(
                    name: "Buffer Linear",
                    package: "swift-buffer-linear"
                ),
                .product(
                    name: "Ownership Shared Primitive",
                    package: "swift-ownership-shared"
                ),
            ]
        ),

        .target(
            name: "Binary Parseable",
            dependencies: [
                "Binary Parse",
                .product(name: "Binary", package: "swift-binary"),
                .product(name: "Byte", package: "swift-byte"),
                .product(
                    name: "Byte Standard Library Integration",
                    package: "swift-byte"
                ),
            ]
        ),

        .target(
            name: "Binary Integer",
            dependencies: [
                "Binary Parse",

                .product(
                    name: "Binary LEB128",
                    package: "swift-binary-leb128"
                ),
            ]
        ),

        .target(
            name: "Binary Parser",
            dependencies: [

                "Binary Input",
                "Binary Machine",
                "Binary Borrowed",
                "Binary Parse",
                "Binary Parseable",
                "Binary Integer",
            ]
        ),

        .target(
            name: "Binary Parser Test Support",
            dependencies: [
                "Binary Parser",
                "Binary Parseable",
                .product(
                    name: "Binary Test Support",
                    package: "swift-binary"
                ),
                .product(
                    name: "Byte Standard Library Integration",
                    package: "swift-byte"
                ),
                .product(name: "Index Test Support", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Binary Input Tests",
            dependencies: ["Binary Parser Test Support"]
        ),
        .testTarget(
            name: "Binary Borrowed Tests",
            dependencies: ["Binary Parser Test Support"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
