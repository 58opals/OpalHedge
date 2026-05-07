// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "OpalHedge",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .watchOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "OpalHedge",
            targets: ["OpalHedge"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/58opals/OpalCrypto.git", branch: "develop")
    ],
    targets: [
        .target(
            name: "OpalHedge",
            dependencies: [
                "OpalHedgeCore",
                "OpalHedgeOracle",
                "OpalHedgeBitcoinCash",
                "OpalHedgeClient"
            ]
        ),
        .target(name: "OpalHedgeCore"),
        .target(
            name: "OpalHedgeOracle",
            dependencies: [
                .product(name: "OpalCrypto", package: "OpalCrypto")
            ]
        ),
        .target(
            name: "OpalHedgeBitcoinCash",
            dependencies: [
                .product(name: "OpalCrypto", package: "OpalCrypto")
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
                "OpalHedgeClient"
            ]
        )
    ]
)
