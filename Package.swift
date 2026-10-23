// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "OpalHedge",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .watchOS(.v27),
        .tvOS(.v27),
        .visionOS(.v27)
    ],
    products: [
        .library(
            name: "OpalHedge",
            targets: ["OpalHedge"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/58opals/OpalCrypto.git", revision: "51fc53c50a66779ca23d564168351da8ecd00faf"),
        .package(url: "https://github.com/58opals/OpalDiagnostics.git", branch: "develop")
    ],
    targets: [
        .target(
            name: "OpalHedge",
            dependencies: [
                "OpalHedgeCore",
                "OpalHedgeOracle",
                "OpalHedgeBitcoinCash",
                "OpalHedgeClient",
                .product(name: "OpalDiagnostics", package: "OpalDiagnostics")
            ]
        ),
        .target(
            name: "OpalHedgeCore",
            dependencies: [
                .product(name: "OpalDiagnostics", package: "OpalDiagnostics")
            ]
        ),
        .target(
            name: "OpalHedgeOracle",
            dependencies: [
                .product(name: "OpalCrypto", package: "OpalCrypto"),
                .product(name: "OpalDiagnostics", package: "OpalDiagnostics")
            ]
        ),
        .target(
            name: "OpalHedgeBitcoinCash",
            dependencies: [
                .product(name: "OpalCrypto", package: "OpalCrypto"),
                .product(name: "OpalDiagnostics", package: "OpalDiagnostics")
            ]
        ),
        .target(name: "OpalHedgeClient"),
        .testTarget(
            name: "OpalHedgeTests",
            dependencies: [
                "OpalHedge",
                "OpalHedgeCore",
                "OpalHedgeOracle",
                "OpalHedgeBitcoinCash",
                "OpalHedgeClient",
                .product(name: "OpalDiagnostics", package: "OpalDiagnostics")
            ]
        )
    ]
)
