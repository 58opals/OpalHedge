// OpalHedgeCoreContractConstraintEvaluator~Funding.swift

import OpalDiagnostics

extension OpalHedgeCoreContractConstraintEvaluator {
    public static func validatePlanDerivationContext(
        _ context: OpalHedgeCoreContractPlanDerivationContext
    ) throws {
        do {
            try performValidatePlanDerivationContext(context)
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintsValidated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_plan_derivation_context"),
                    OpalDiagnostics.Field.moduleField("core")
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintValidationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_plan_derivation_context"),
                    OpalDiagnostics.Field.moduleField("core")
                ] + OpalDiagnostics.Field.makeConstraintFields(for: error)
                    + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func performValidatePlanDerivationContext(
        _ context: OpalHedgeCoreContractPlanDerivationContext
    ) throws {
        let expectedFundingAmounts = try OpalHedgeCoreContractFundingAmounts(
            from: context.creationContext
        )

        try validateFundingAmounts(context.fundingAmounts)
        try validateFundingAmounts(
            context.fundingAmounts,
            match: expectedFundingAmounts
        )
    }

    public static func validateFundingAmounts(
        _ amounts: OpalHedgeCoreContractFundingAmounts
    ) throws {
        do {
            try performValidateFundingAmounts(amounts)
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintsValidated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_funding_amounts"),
                    OpalDiagnostics.Field.moduleField("core"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.satoshiCount,
                        amounts.payoutSats
                    )
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintValidationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_funding_amounts"),
                    OpalDiagnostics.Field.moduleField("core")
                ] + OpalDiagnostics.Field.makeConstraintFields(for: error)
                    + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func performValidateFundingAmounts(
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
        guard amounts.satsForNominalUnitsAtLowLiquidation <=
              OpalHedgeCoreContractConstraintPolicy.maxContractSatoshis else {
            throw OpalHedgeCoreContractConstraintError
                .contractSatoshisExceedMaximum(
                    amounts.satsForNominalUnitsAtLowLiquidation
                )
        }
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
