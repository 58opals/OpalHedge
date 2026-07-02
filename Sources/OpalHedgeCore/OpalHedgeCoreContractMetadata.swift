// OpalHedgeCoreContractMetadata.swift

public struct OpalHedgeCoreContractMetadata: Sendable, Equatable {
    public let takerSide: OpalHedgeCoreContractSide
    public let makerSide: OpalHedgeCoreContractSide
    public let shortPayoutAddress: OpalHedgeCoreContractPayoutAddress
    public let longPayoutAddress: OpalHedgeCoreContractPayoutAddress
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
        shortPayoutAddress: OpalHedgeCoreContractPayoutAddress,
        longPayoutAddress: OpalHedgeCoreContractPayoutAddress,
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

    public init(from context: OpalHedgeCoreContractPlanDerivationContext) throws {
        let creationContext = context.creationContext
        let fundingAmounts = context.fundingAmounts
        let startingOracleProof = creationContext.startingOracleProof
        self.init(
            takerSide: creationContext.takerSide,
            makerSide: creationContext.makerSide,
            shortPayoutAddress: creationContext.shortPayoutAddress,
            longPayoutAddress: creationContext.longPayoutAddress,
            startingOracleMessageHex: startingOracleProof.messageHex,
            startingOracleSignatureHex: startingOracleProof.signatureHex,
            startPrice: startingOracleProof.priceValue,
            durationInSeconds: creationContext.maturityTimestamp
                - startingOracleProof.messageTimestamp,
            nominalUnits: creationContext.nominalUnits,
            lowLiquidationPriceMultiplier: creationContext.lowLiquidationPriceMultiplier,
            highLiquidationPriceMultiplier: creationContext.highLiquidationPriceMultiplier,
            isSimpleHedge: creationContext.isSimpleHedge,
            shortInputInOracleUnits: Self.oracleUnits(
                for: fundingAmounts.shortInputInSatoshis,
                startPrice: startingOracleProof.priceValue
            ),
            longInputInOracleUnits: Self.oracleUnits(
                for: fundingAmounts.longInputInSatoshis,
                startPrice: startingOracleProof.priceValue
            ),
            shortInputInSatoshis: fundingAmounts.shortInputInSatoshis,
            longInputInSatoshis: fundingAmounts.longInputInSatoshis,
            minerCostInSatoshis: creationContext.minerCostInSatoshis
        )
    }

    private static func oracleUnits(for satoshis: Int64, startPrice: Int64) -> Double {
        let satoshisPerBitcoinCash = Double(
            OpalHedgeCoreContractConstraintPolicy.satoshisPerBitcoinCash
        )

        return (Double(satoshis) / satoshisPerBitcoinCash) * Double(startPrice)
    }
}
