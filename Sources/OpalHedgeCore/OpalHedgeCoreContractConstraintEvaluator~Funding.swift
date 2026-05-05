// OpalHedgeCoreContractConstraintEvaluator~Funding.swift

extension OpalHedgeCoreContractConstraintEvaluator {
    public static func validatePlanDerivationContext(
        _ context: OpalHedgeCoreContractPlanDerivationContext
    ) throws {
        try validateCreationContext(context.creationContext)
        try validateFundingAmounts(context.fundingAmounts)
        try validateFundingAmounts(
            context.fundingAmounts,
            match: OpalHedgeCoreContractFundingAmounts(from: context.creationContext)
        )
    }

    public static func validateFundingAmounts(
        _ amounts: OpalHedgeCoreContractFundingAmounts
    ) throws {
        try validatePriceOracleUnits(amounts.lowLiquidationPrice, name: "lowLiquidationPrice")
        try validatePriceOracleUnits(amounts.highLiquidationPrice, name: "highLiquidationPrice")
        try validatePositiveInteger(
            amounts.nominalUnitsXSatsPerBitcoinCash,
            name: "nominalUnitsXSatsPerBitcoinCash"
        )
        try validateNonnegativeInteger(
            amounts.satsForNominalUnitsAtHighLiquidation,
            name: "satsForNominalUnitsAtHighLiquidation"
        )
        try validatePositiveInteger(
            amounts.satsForNominalUnitsAtLowLiquidation,
            name: "satsForNominalUnitsAtLowLiquidation"
        )
        try validatePositiveInteger(
            amounts.satsForNominalUnitsAtStart,
            name: "satsForNominalUnitsAtStart"
        )
        try validateDerivedFunding(
            shortInputInSatoshis: amounts.shortInputInSatoshis,
            longInputInSatoshis: amounts.longInputInSatoshis,
            payoutSats: amounts.payoutSats
        )
    }

    static func validateFundingAmounts(
        _ amounts: OpalHedgeCoreContractFundingAmounts,
        match expected: OpalHedgeCoreContractFundingAmounts
    ) throws {
        try validateFundingAmount(
            amounts.lowLiquidationPrice,
            expected: expected.lowLiquidationPrice,
            name: "lowLiquidationPrice"
        )
        try validateFundingAmount(
            amounts.highLiquidationPrice,
            expected: expected.highLiquidationPrice,
            name: "highLiquidationPrice"
        )
        try validateFundingAmount(
            amounts.nominalUnitsXSatsPerBitcoinCash,
            expected: expected.nominalUnitsXSatsPerBitcoinCash,
            name: "nominalUnitsXSatsPerBitcoinCash"
        )
        try validateFundingAmount(
            amounts.satsForNominalUnitsAtHighLiquidation,
            expected: expected.satsForNominalUnitsAtHighLiquidation,
            name: "satsForNominalUnitsAtHighLiquidation"
        )
        try validateFundingAmount(
            amounts.satsForNominalUnitsAtLowLiquidation,
            expected: expected.satsForNominalUnitsAtLowLiquidation,
            name: "satsForNominalUnitsAtLowLiquidation"
        )
        try validateFundingAmount(
            amounts.satsForNominalUnitsAtStart,
            expected: expected.satsForNominalUnitsAtStart,
            name: "satsForNominalUnitsAtStart"
        )
        try validateFundingAmount(
            amounts.shortInputInSatoshis,
            expected: expected.shortInputInSatoshis,
            name: "shortInputInSatoshis"
        )
        try validateFundingAmount(
            amounts.longInputInSatoshis,
            expected: expected.longInputInSatoshis,
            name: "longInputInSatoshis"
        )
        try validateFundingAmount(
            amounts.payoutSats,
            expected: expected.payoutSats,
            name: "payoutSats"
        )
    }

    private static func validateFundingAmount(
        _ value: Int64,
        expected: Int64,
        name: String
    ) throws {
        guard value == expected else {
            throw OpalHedgeCoreContractConstraintError.inconsistentContractFundingAmount(
                name: name,
                expected: expected,
                actual: value
            )
        }
    }
}
