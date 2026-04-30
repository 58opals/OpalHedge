// OpalHedgeCoreContractPreset.swift

public struct OpalHedgeCoreContractPreset: Sendable, Equatable {
    public let unitCode: String
    public let side: OpalHedgeCoreContractSide
    public let durationInSeconds: Int64
    public let isSimpleHedge: Int64
    public let lowLiquidationPriceMultiplier: Double
    public let highLiquidationPriceMultiplier: Double

    public static let usdSimpleHedgeThirtyDay = Self(
        unitCode: "USD",
        side: .short,
        durationInSeconds: 2_592_000,
        isSimpleHedge: 1,
        lowLiquidationPriceMultiplier: 0.75,
        highLiquidationPriceMultiplier: 10.0
    )

    public init(
        unitCode: String,
        side: OpalHedgeCoreContractSide,
        durationInSeconds: Int64,
        isSimpleHedge: Int64,
        lowLiquidationPriceMultiplier: Double,
        highLiquidationPriceMultiplier: Double
    ) {
        self.unitCode = unitCode
        self.side = side
        self.durationInSeconds = durationInSeconds
        self.isSimpleHedge = isSimpleHedge
        self.lowLiquidationPriceMultiplier = lowLiquidationPriceMultiplier
        self.highLiquidationPriceMultiplier = highLiquidationPriceMultiplier
    }
}
