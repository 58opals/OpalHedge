// OpalHedgeCoreContractMetadata.swift

public struct OpalHedgeCoreContractMetadata: Sendable, Equatable {
    public let takerSide: OpalHedgeCoreContractSide
    public let makerSide: OpalHedgeCoreContractSide
    public let shortPayoutAddress: String
    public let longPayoutAddress: String
    public let startingOracleMessageHex: String
    public let startingOracleSignatureHex: String
    public let startPrice: Int64
    public let durationInSeconds: Int64
    public let nominalUnits: Double
    public let lowLiquidationPriceMultiplier: Double
    public let highLiquidationPriceMultiplier: Double
    public let isSimpleHedge: Int64
    public let shortInputInOracleUnits: Double
    public let longInputInOracleUnits: Double
    public let shortInputInSatoshis: Int64
    public let longInputInSatoshis: Int64
    public let minerCostInSatoshis: Int64

    public init(
        takerSide: OpalHedgeCoreContractSide,
        makerSide: OpalHedgeCoreContractSide,
        shortPayoutAddress: String,
        longPayoutAddress: String,
        startingOracleMessageHex: String,
        startingOracleSignatureHex: String,
        startPrice: Int64,
        durationInSeconds: Int64,
        nominalUnits: Double,
        lowLiquidationPriceMultiplier: Double,
        highLiquidationPriceMultiplier: Double,
        isSimpleHedge: Int64,
        shortInputInOracleUnits: Double,
        longInputInOracleUnits: Double,
        shortInputInSatoshis: Int64,
        longInputInSatoshis: Int64,
        minerCostInSatoshis: Int64
    ) {
        self.takerSide = takerSide
        self.makerSide = makerSide
        self.shortPayoutAddress = shortPayoutAddress
        self.longPayoutAddress = longPayoutAddress
        self.startingOracleMessageHex = startingOracleMessageHex
        self.startingOracleSignatureHex = startingOracleSignatureHex
        self.startPrice = startPrice
        self.durationInSeconds = durationInSeconds
        self.nominalUnits = nominalUnits
        self.lowLiquidationPriceMultiplier = lowLiquidationPriceMultiplier
        self.highLiquidationPriceMultiplier = highLiquidationPriceMultiplier
        self.isSimpleHedge = isSimpleHedge
        self.shortInputInOracleUnits = shortInputInOracleUnits
        self.longInputInOracleUnits = longInputInOracleUnits
        self.shortInputInSatoshis = shortInputInSatoshis
        self.longInputInSatoshis = longInputInSatoshis
        self.minerCostInSatoshis = minerCostInSatoshis
    }
}
