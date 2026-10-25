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
        .package(url: "https://github.com/58opals/OpalCrypto.git", revision: "06f9edcbd5b44c869e6f81f3da1ea147add1d8cf"),
        .package(url: "https://github.com/58opals/OpalDiagnostics.git", revision: "aa56dec5d6c8581beb2b3cef43b03dd577ccd9f1")
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
