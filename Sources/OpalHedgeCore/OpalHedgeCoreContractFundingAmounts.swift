// OpalHedgeCoreContractFundingAmounts.swift

public struct OpalHedgeCoreContractFundingAmounts: Sendable, Equatable {
    public let lowLiquidationPrice: Int64
    public let highLiquidationPrice: Int64
    public let nominalUnitsXSatsPerBitcoinCash: Int64
    public let satsForNominalUnitsAtHighLiquidation: Int64
    public let satsForNominalUnitsAtLowLiquidation: Int64
    public let satsForNominalUnitsAtStart: Int64
    public let shortInputInSatoshis: Int64
    public let longInputInSatoshis: Int64
    public let payoutSats: Int64

    public init(from context: OpalHedgeCoreContractCreationContext) throws {
        try OpalHedgeCoreContractConstraintEvaluator.validateCreationContext(context)

        let startingOracleProof = context.startingOracleProof
        let lowLiquidationPrice = try OpalHedgeCoreContractConstraintEvaluator.roundedPrice(
            startPrice: startingOracleProof.priceValue,
            multiplier: context.lowLiquidationPriceMultiplier,
            name: "lowLiquidationPrice"
        )
        let highLiquidationPrice = try OpalHedgeCoreContractConstraintEvaluator.roundedPrice(
            startPrice: startingOracleProof.priceValue,
            multiplier: context.highLiquidationPriceMultiplier,
            name: "highLiquidationPrice"
        )
        let nominalUnitsXSatsPerBitcoinCash = try OpalHedgeCoreContractConstraintEvaluator
            .nominalUnitsXSatsPerBitcoinCash(
                for: context.nominalUnits
            )
        let satsForNominalUnitsAtHighLiquidation = context.isSimpleHedge == 0
            ? nominalUnitsXSatsPerBitcoinCash / highLiquidationPrice
            : 0
        let satsForNominalUnitsAtLowLiquidation = nominalUnitsXSatsPerBitcoinCash
            / lowLiquidationPrice
        let payoutSats = satsForNominalUnitsAtLowLiquidation
            - satsForNominalUnitsAtHighLiquidation
        let satsForNominalUnitsAtStart = nominalUnitsXSatsPerBitcoinCash
            / startingOracleProof.priceValue
        let shortInputInSatoshis = satsForNominalUnitsAtStart
            - satsForNominalUnitsAtHighLiquidation
        let longInputInSatoshis = payoutSats - shortInputInSatoshis

        self.lowLiquidationPrice = lowLiquidationPrice
        self.highLiquidationPrice = highLiquidationPrice
        self.nominalUnitsXSatsPerBitcoinCash = nominalUnitsXSatsPerBitcoinCash
        self.satsForNominalUnitsAtHighLiquidation = satsForNominalUnitsAtHighLiquidation
        self.satsForNominalUnitsAtLowLiquidation = satsForNominalUnitsAtLowLiquidation
        self.satsForNominalUnitsAtStart = satsForNominalUnitsAtStart
        self.shortInputInSatoshis = shortInputInSatoshis
        self.longInputInSatoshis = longInputInSatoshis
        self.payoutSats = payoutSats

        try OpalHedgeCoreContractConstraintEvaluator.validateFundingAmounts(self)
    }
}
