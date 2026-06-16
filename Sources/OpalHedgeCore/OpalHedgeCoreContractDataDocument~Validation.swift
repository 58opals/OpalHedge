// OpalHedgeCoreContractDataDocument~Validation.swift

extension OpalHedgeCoreContractDataDocument {
    static func validateDraftData(
        _ draftData: OpalHedgeCoreContractDraftData
    ) throws {
        try validateFiniteMetadataNumbers(draftData.metadata)
        try validateFees(draftData.fees)
        try validateFundings(draftData.fundings)
        try validateStartingOracleMetadata(
            draftData.metadata,
            matches: draftData.parameters
        )
        try OpalHedgeCoreContractConstraintEvaluator.validateParameters(
            draftData.parameters,
            startPrice: draftData.metadata.startPrice
        )
        try OpalHedgeCoreContractConstraintEvaluator.validateDerivedFunding(
            shortInputInSatoshis: draftData.metadata.shortInputInSatoshis,
            longInputInSatoshis: draftData.metadata.longInputInSatoshis,
            payoutSats: draftData.parameters.payoutSats
        )
        try validateMetadata(
            draftData.metadata,
            matches: draftData.parameters
        )
    }

    static func validateFiniteMetadataNumbers(
        _ metadata: OpalHedgeCoreContractMetadata
    ) throws {
        try validateFiniteNumber(metadata.nominalUnits, name: "nominalUnits")
        try validateFiniteNumber(
            metadata.lowLiquidationPriceMultiplier,
            name: "lowLiquidationPriceMultiplier"
        )
        try validateFiniteNumber(
            metadata.highLiquidationPriceMultiplier,
            name: "highLiquidationPriceMultiplier"
        )
        try validateFiniteNumber(
            metadata.shortInputInOracleUnits,
            name: "hedgeInputInOracleUnits"
        )
        try validateFiniteNumber(
            metadata.longInputInOracleUnits,
            name: "longInputInOracleUnits"
        )
        try OpalHedgeCoreContractConstraintEvaluator.validateNonnegativeInteger(
            metadata.minerCostInSatoshis,
            name: "minerCostInSatoshis"
        )
    }

    static func validateFiniteNumber(_ value: Double, name: String) throws {
        guard value.isFinite else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "finite number"
            )
        }
    }

    static func validateFees(
        _ fees: [OpalHedgeCoreContractFeeData]
    ) throws {
        for (index, fee) in fees.enumerated() {
            _ = try OpalHedgeCoreContractConstraintEvaluator.validatePayoutAddress(
                fee.address,
                name: "fees[\(index)].address"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validatePositiveInteger(
                fee.satoshis,
                name: "fees[\(index)].satoshis"
            )
        }
    }
}
