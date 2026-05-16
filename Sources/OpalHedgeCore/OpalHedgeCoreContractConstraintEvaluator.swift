// OpalHedgeCoreContractConstraintEvaluator.swift

public enum OpalHedgeCoreContractConstraintEvaluator {
    public static func validateCreationContext(
        _ context: OpalHedgeCoreContractCreationContext
    ) throws {
        do {
            try performValidateCreationContext(context)
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintsValidated,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_creation_context"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ]
            )
        } catch {
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintValidationFailed,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_creation_context"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ] + OpalHedgeCoreDiagnostics.makeConstraintFields(for: error)
                    + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
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

    public static func validateStartingOracleProof(
        _ proof: OpalHedgeCoreContractStartingOracleProof
    ) throws {
        do {
            try validateCompressedPublicKeyHex(proof.oraclePublicKeyHex, name: "oraclePublicKeyHex")
            try validateOracleMessageData(proof.message)
            try validateSchnorrSignatureHex(proof.signatureHex, name: "signatureHex")
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintsValidated,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_starting_oracle_proof"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ]
            )
        } catch {
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintValidationFailed,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_starting_oracle_proof"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ] + OpalHedgeCoreDiagnostics.makeConstraintFields(for: error)
                    + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    package static func validateMetadataContext(
        _ context: OpalHedgeCoreContractMetadataContext
    ) throws {
        _ = try OpalHedgeCoreContractPlanDerivationContext(
            creationContext: context.creationContext,
            fundingAmounts: context.fundingAmounts
        )
    }

    public static func validateOracleMessageData(
        _ message: OpalHedgeCoreContractOracleMessageData
    ) throws {
        do {
            try validateOracleMessageHex(message.hex, name: "messageHex")
            try validateFourBytePositiveScriptInteger(message.messageTimestamp, name: "messageTimestamp")
            try validateFourBytePositiveScriptInteger(message.messageSequence, name: "messageSequence")
            try validateFourBytePositiveScriptInteger(message.priceSequence, name: "priceSequence")
            try validateFourBytePositiveScriptInteger(message.priceValue, name: "priceValue")
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintsValidated,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_oracle_message_data"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ]
            )
        } catch {
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintValidationFailed,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_oracle_message_data"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ] + OpalHedgeCoreDiagnostics.makeConstraintFields(for: error)
                    + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    public static func validateParameters(
        _ parameters: OpalHedgeCoreContractParameters,
        startPrice: Int64
    ) throws {
        do {
            try performValidateParameters(parameters, startPrice: startPrice)
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintsValidated,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_parameters"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ]
            )
        } catch {
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintValidationFailed,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_parameters"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ] + OpalHedgeCoreDiagnostics.makeConstraintFields(for: error)
                    + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
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

    public static func validateDerivedFunding(
        shortInputInSatoshis: Int64,
        longInputInSatoshis: Int64,
        payoutSats: Int64
    ) throws {
        do {
            let totalInput = shortInputInSatoshis.addingReportingOverflow(
                longInputInSatoshis
            )
            guard shortInputInSatoshis > 0,
                  longInputInSatoshis > 0,
                  payoutSats > 0,
                  !totalInput.overflow,
                  totalInput.partialValue == payoutSats else {
                throw OpalHedgeCoreContractConstraintError.invalidContractFunding(
                    shortInput: shortInputInSatoshis,
                    longInput: longInputInSatoshis,
                    payoutSats: payoutSats
                )
            }
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintsValidated,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_derived_funding"),
                    OpalHedgeCoreDiagnostics.moduleField("core"),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.satoshiCount,
                        payoutSats
                    )
                ]
            )
        } catch {
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractConstraintValidationFailed,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("validate_derived_funding"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ] + OpalHedgeCoreDiagnostics.makeConstraintFields(for: error)
                    + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    static func validatePayoutAddress(
        _ address: OpalHedgeCoreContractPayoutAddress,
        matches lockScript: OpalHedgeCoreContractLockScript,
        name: String
    ) throws {
        guard address.publicKeyHashHex == lockScript.publicKeyHashHex else {
            throw OpalHedgeCoreContractConstraintError
                .inconsistentPayoutAddressLockScript(
                    name: name,
                    addressPublicKeyHashHex: address.publicKeyHashHex,
                    lockScriptPublicKeyHashHex: lockScript.publicKeyHashHex
                )
        }
    }

    static func roundedPrice(startPrice: Int64, multiplier: Double, name: String) throws -> Int64 {
        try roundedInt64(Double(startPrice) * multiplier, name: name)
    }

    static func nominalUnitsXSatsPerBitcoinCash(for nominalUnits: Double) throws -> Int64 {
        try roundedInt64(
            nominalUnits * Double(OpalHedgeCoreContractConstraintPolicy.satoshisPerBitcoinCash),
            name: "nominalUnitsXSatsPerBch"
        )
    }
}
