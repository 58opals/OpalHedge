// OpalHedgeCoreContractDataDocumentDecoder.swift

enum OpalHedgeCoreContractDataDocumentDecoder {
    static func draftData(
        from dictionary: [String: Any]
    ) throws -> OpalHedgeCoreContractDraftData {
        let parameters = try parameters(from: try childDictionary("parameters", in: dictionary))
        let metadata = try metadata(
            from: try childDictionary("metadata", in: dictionary),
            parameters: parameters
        )
        let fundings = try childDictionaryArray("fundings", in: dictionary).map(funding)
        let fees = try childDictionaryArray("fees", in: dictionary).map(feeData)

        try OpalHedgeCoreContractConstraintEvaluator.validateParameters(
            parameters,
            startPrice: metadata.startPrice
        )

        return OpalHedgeCoreContractDraftData(
            parameters: parameters,
            metadata: metadata,
            fundings: fundings,
            fees: fees
        )
    }

    static func parameters(
        from dictionary: [String: Any]
    ) throws -> OpalHedgeCoreContractParameters {
        try OpalHedgeCoreContractParameters(
            oraclePublicKeyHex: string("oraclePublicKey", in: dictionary),
            lowLiquidationPrice: int64("lowLiquidationPrice", in: dictionary),
            highLiquidationPrice: int64("highLiquidationPrice", in: dictionary),
            startTimestamp: int64("startTimestamp", in: dictionary),
            maturityTimestamp: int64("maturityTimestamp", in: dictionary),
            nominalUnitsXSatsPerBch: int64("nominalUnitsXSatsPerBch", in: dictionary),
            satsForNominalUnitsAtHighLiquidation: int64(
                "satsForNominalUnitsAtHighLiquidation",
                in: dictionary
            ),
            payoutSats: int64("payoutSats", in: dictionary),
            shortLockScriptHex: string("hedgeLockScript", in: dictionary),
            longLockScriptHex: string("longLockScript", in: dictionary),
            enableMutualRedemption: int64("enableMutualRedemption", in: dictionary),
            shortMutualRedeemPublicKeyHex: string(
                "hedgeMutualRedeemPublicKey",
                in: dictionary
            ),
            longMutualRedeemPublicKeyHex: string(
                "longMutualRedeemPublicKey",
                in: dictionary
            )
        )
    }

    static func metadata(
        from dictionary: [String: Any],
        parameters: OpalHedgeCoreContractParameters
    ) throws -> OpalHedgeCoreContractMetadata {
        let startingOracleMessageHex = try string("startingOracleMessage", in: dictionary)
        let startingOracleSignatureHex = try string("startingOracleSignature", in: dictionary)
        _ = try OpalHedgeCoreContractOracleMessageData(hex: startingOracleMessageHex)
        _ = try OpalHedgeCoreContractOracleSignature(hex: startingOracleSignatureHex)

        return try OpalHedgeCoreContractMetadata(
            takerSide: side("takerSide", in: dictionary),
            makerSide: side("makerSide", in: dictionary),
            shortPayoutAddress: OpalHedgeCoreContractPayoutAddress(
                string("hedgePayoutAddress", in: dictionary)
            ),
            longPayoutAddress: OpalHedgeCoreContractPayoutAddress(
                string("longPayoutAddress", in: dictionary)
            ),
            startingOracleMessageHex: startingOracleMessageHex,
            startingOracleSignatureHex: startingOracleSignatureHex,
            startPrice: int64("startPrice", in: dictionary),
            durationInSeconds: int64("durationInSeconds", in: dictionary),
            nominalUnits: double("nominalUnits", in: dictionary),
            lowLiquidationPriceMultiplier: double(
                "lowLiquidationPriceMultiplier",
                in: dictionary
            ),
            highLiquidationPriceMultiplier: double(
                "highLiquidationPriceMultiplier",
                in: dictionary
            ),
            isSimpleHedge: parameters.satsForNominalUnitsAtHighLiquidation == 0 ? 1 : 0,
            shortInputInOracleUnits: double("hedgeInputInOracleUnits", in: dictionary),
            longInputInOracleUnits: double("longInputInOracleUnits", in: dictionary),
            shortInputInSatoshis: int64("hedgeInputInSatoshis", in: dictionary),
            longInputInSatoshis: int64("longInputInSatoshis", in: dictionary),
            minerCostInSatoshis: int64("minerCostInSatoshis", in: dictionary)
        )
    }

    static func funding(
        from dictionary: [String: Any]
    ) throws -> OpalHedgeCoreContractFunding {
        try OpalHedgeCoreContractFunding(
            fundingTransactionHash: string("fundingTransactionHash", in: dictionary),
            fundingOutputIndex: int64("fundingOutputIndex", in: dictionary),
            fundingSatoshis: int64("fundingSatoshis", in: dictionary),
            settlement: optionalChildDictionary("settlement", in: dictionary).map(settlement)
        )
    }

    static func settlement(
        from dictionary: [String: Any]
    ) throws -> OpalHedgeCoreContractSettlement {
        let settlementType = try string("settlementType", in: dictionary)
        guard let kind = OpalHedgeCoreSettlementKind(rawValue: settlementType) else {
            throw OpalHedgeCoreContractDataDocumentError.invalidSettlementType(
                settlementType
            )
        }

        return try OpalHedgeCoreContractSettlement(
            kind: kind,
            settlementTransactionHash: string("settlementTransactionHash", in: dictionary),
            shortPayoutInSatoshis: int64("hedgePayoutInSatoshis", in: dictionary),
            longPayoutInSatoshis: int64("longPayoutInSatoshis", in: dictionary),
            settlementMessageHex: optionalString("settlementMessage", in: dictionary),
            settlementSignatureHex: optionalString("settlementSignature", in: dictionary),
            previousMessageHex: optionalString("previousMessage", in: dictionary),
            previousSignatureHex: optionalString("previousSignature", in: dictionary),
            settlementPrice: optionalInt64("settlementPrice", in: dictionary)
        )
    }

    static func feeData(
        from dictionary: [String: Any]
    ) throws -> OpalHedgeCoreContractFeeData {
        try OpalHedgeCoreContractFeeData(
            name: string("name", in: dictionary),
            description: string("description", in: dictionary),
            address: string("address", in: dictionary),
            satoshis: int64("satoshis", in: dictionary)
        )
    }
}
