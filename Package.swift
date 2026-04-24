// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "OpalHedge",
    products: [
        .library(
            name: "OpalHedge",
            targets: ["OpalHedge"]
        )
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
        .target(name: "OpalHedgeOracle"),
        .target(name: "OpalHedgeBitcoinCash"),
        .target(name: "OpalHedgeClient"),
        .testTarget(
            name: "OpalHedgeTests",
            dependencies: ["OpalHedge"]
        )
    ]
)
