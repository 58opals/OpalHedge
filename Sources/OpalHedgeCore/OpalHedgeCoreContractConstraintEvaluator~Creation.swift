// OpalHedgeCoreContractConstraintEvaluator~Creation.swift

import OpalDiagnostics

extension OpalHedgeCoreContractConstraintEvaluator {
    public static func validateCreationContext(
        _ context: OpalHedgeCoreContractCreationContext
    ) throws {
        do {
            try performValidateCreationContext(context)
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintsValidated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_creation_context"),
                    OpalDiagnostics.Field.moduleField("core")
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintValidationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_creation_context"),
                    OpalDiagnostics.Field.moduleField("core")
                ] + OpalDiagnostics.Field.makeConstraintFields(for: error)
                    + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func performValidateCreationContext(
        _ context: OpalHedgeCoreContractCreationContext
    ) throws {
        guard context.makerSide != context.takerSide else {
            throw OpalHedgeCoreContractConstraintError.makerSideMustOpposeTaker(
                taker: context.takerSide,
                maker: context.makerSide
            )
        }

        try validateStartingOracleProof(context.startingOracleProof)
        _ = try validatePayoutAddress(context.shortPayoutAddress.rawValue, name: "shortPayoutAddress")
        _ = try validatePayoutAddress(context.longPayoutAddress.rawValue, name: "longPayoutAddress")
        try validateLockScriptHex(context.shortLockScript.hex, name: "shortLockScript")
        try validateLockScriptHex(context.longLockScript.hex, name: "longLockScript")
        try validatePayoutAddress(
            context.shortPayoutAddress,
            matches: context.shortLockScript,
            name: "shortPayoutAddress"
        )
        try validatePayoutAddress(
            context.longPayoutAddress,
            matches: context.longLockScript,
            name: "longPayoutAddress"
        )
        try validateCompressedPublicKeyHex(
            context.shortMutualRedeemPublicKey.hex,
            name: "shortMutualRedeemPublicKey"
        )
        try validateCompressedPublicKeyHex(
            context.longMutualRedeemPublicKey.hex,
            name: "longMutualRedeemPublicKey"
        )
        try validateFourBytePositiveScriptInteger(context.maturityTimestamp, name: "maturityTimestamp")
        try validateBooleanInteger(context.isSimpleHedge, name: "isSimpleHedge")
        try validateBooleanInteger(context.enableMutualRedemption, name: "enableMutualRedemption")
        try validateNonnegativeInteger(context.minerCostInSatoshis, name: "minerCostInSatoshis")
        guard context.maturityTimestamp > context.startingOracleProof.messageTimestamp else {
            throw OpalHedgeCoreContractConstraintError.invalidPositiveInteger(
                name: "maturityTimestamp",
                value: context.maturityTimestamp
            )
        }

        guard context.nominalUnits.isFinite, context.nominalUnits > 0 else {
            throw OpalHedgeCoreContractConstraintError.invalidNominalUnits(context.nominalUnits)
        }

        try validateMultiplier(
            context.lowLiquidationPriceMultiplier,
            name: "lowLiquidationPriceMultiplier"
        )
        try validateMultiplier(
            context.highLiquidationPriceMultiplier,
            name: "highLiquidationPriceMultiplier"
        )

        let lowLiquidationPrice = try roundedPrice(
            startPrice: context.startingOracleProof.priceValue,
            multiplier: context.lowLiquidationPriceMultiplier,
            name: "lowLiquidationPrice"
        )
        let highLiquidationPrice = try roundedPrice(
            startPrice: context.startingOracleProof.priceValue,
            multiplier: context.highLiquidationPriceMultiplier,
            name: "highLiquidationPrice"
        )

        try validateLiquidationRange(
            lowLiquidationPrice: lowLiquidationPrice,
            highLiquidationPrice: highLiquidationPrice,
            startPrice: context.startingOracleProof.priceValue
        )
        _ = try nominalUnitsXSatsPerBitcoinCash(for: context.nominalUnits)
    }
}
