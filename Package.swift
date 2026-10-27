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
        .package(url: "https://github.com/58opals/OpalCrypto.git", revision: "cdd407d32d762ee77477914a142fa9700789e839"),
        .package(url: "https://github.com/58opals/OpalDiagnostics.git", revision: "393325d11591bf87c65288f7755337491b4b41b1")
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
