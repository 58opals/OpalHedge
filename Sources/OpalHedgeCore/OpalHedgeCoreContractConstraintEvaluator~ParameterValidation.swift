// OpalHedgeCoreContractConstraintEvaluator~ParameterValidation.swift

import OpalDiagnostics

extension OpalHedgeCoreContractConstraintEvaluator {
    public static func validateParameters(
        _ parameters: OpalHedgeCoreContractParameters,
        startPrice: Int64
    ) throws {
        do {
            try performValidateParameters(parameters, startPrice: startPrice)
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintsValidated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_parameters"),
                    OpalDiagnostics.Field.moduleField("core")
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintValidationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_parameters"),
                    OpalDiagnostics.Field.moduleField("core")
                ] + OpalDiagnostics.Field.makeConstraintFields(for: error)
                    + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func performValidateParameters(
        _ parameters: OpalHedgeCoreContractParameters,
        startPrice: Int64
    ) throws {
        try validateFourBytePositiveScriptInteger(startPrice, name: "startPrice")
        try validateFourBytePositiveScriptInteger(parameters.startTimestamp, name: "startTimestamp")
        try validateFourBytePositiveScriptInteger(parameters.maturityTimestamp, name: "maturityTimestamp")
        try validateCompressedPublicKeyHex(parameters.oraclePublicKey.hex, name: "oraclePublicKey")
        try validateLockScriptHex(parameters.shortLockScript.hex, name: "shortLockScript")
        try validateLockScriptHex(parameters.longLockScript.hex, name: "longLockScript")
        try validateCompressedPublicKeyHex(
            parameters.shortMutualRedeemPublicKey.hex,
            name: "shortMutualRedeemPublicKey"
        )
        try validateCompressedPublicKeyHex(
            parameters.longMutualRedeemPublicKey.hex,
            name: "longMutualRedeemPublicKey"
        )
        guard parameters.maturityTimestamp > parameters.startTimestamp else {
            throw OpalHedgeCoreContractConstraintError.invalidPositiveInteger(
                name: "maturityTimestamp",
                value: parameters.maturityTimestamp
            )
        }

        try validatePriceOracleUnits(parameters.lowLiquidationPrice, name: "lowLiquidationPrice")
        try validatePriceOracleUnits(parameters.highLiquidationPrice, name: "highLiquidationPrice")
        try validateLiquidationRange(
            lowLiquidationPrice: parameters.lowLiquidationPrice,
            highLiquidationPrice: parameters.highLiquidationPrice,
            startPrice: startPrice
        )
        try validatePositiveInteger(parameters.nominalUnitsXSatsPerBch, name: "nominalUnitsXSatsPerBch")
        try validateNonnegativeInteger(
            parameters.satsForNominalUnitsAtHighLiquidation,
            name: "satsForNominalUnitsAtHighLiquidation"
        )
        try validateBooleanInteger(parameters.enableMutualRedemption, name: "enableMutualRedemption")
        try validatePayoutSatoshis(parameters.payoutSats)
        try validateExecutionSafety(parameters)
    }
}
