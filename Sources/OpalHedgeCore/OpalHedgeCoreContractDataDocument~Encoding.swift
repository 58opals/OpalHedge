// OpalHedgeCoreContractDataDocument~Encoding.swift

extension OpalHedgeCoreContractDataDocument {
    static func dictionary(
        for draftData: OpalHedgeCoreContractDraftData
    ) -> [String: Any] {
        [
            "fees": draftData.fees.map(feeDictionary),
            "fundings": draftData.fundings.map(fundingDictionary),
            "metadata": metadataDictionary(for: draftData.metadata),
            "parameters": parametersDictionary(for: draftData.parameters)
        ]
    }

    private static func parametersDictionary(
        for parameters: OpalHedgeCoreContractParameters
    ) -> [String: Any] {
        [
            "enableMutualRedemption": parameters.enableMutualRedemption,
            "hedgeLockScript": parameters.shortLockScriptHex,
            "hedgeMutualRedeemPublicKey": parameters.shortMutualRedeemPublicKeyHex,
            "highLiquidationPrice": parameters.highLiquidationPrice,
            "longLockScript": parameters.longLockScriptHex,
            "longMutualRedeemPublicKey": parameters.longMutualRedeemPublicKeyHex,
            "lowLiquidationPrice": parameters.lowLiquidationPrice,
            "maturityTimestamp": parameters.maturityTimestamp,
            "nominalUnitsXSatsPerBch": parameters.nominalUnitsXSatsPerBch,
            "oraclePublicKey": parameters.oraclePublicKeyHex,
            "payoutSats": parameters.payoutSats,
            "satsForNominalUnitsAtHighLiquidation":
                parameters.satsForNominalUnitsAtHighLiquidation,
            "startTimestamp": parameters.startTimestamp
        ]
    }

    private static func metadataDictionary(
        for metadata: OpalHedgeCoreContractMetadata
    ) -> [String: Any] {
        [
            "durationInSeconds": metadata.durationInSeconds,
            "hedgeInputInOracleUnits": metadata.shortInputInOracleUnits,
            "hedgeInputInSatoshis": metadata.shortInputInSatoshis,
            "hedgePayoutAddress": metadata.shortPayoutAddress.rawValue,
            "highLiquidationPriceMultiplier": metadata.highLiquidationPriceMultiplier,
            "longInputInOracleUnits": metadata.longInputInOracleUnits,
            "longInputInSatoshis": metadata.longInputInSatoshis,
            "longPayoutAddress": metadata.longPayoutAddress.rawValue,
            "lowLiquidationPriceMultiplier": metadata.lowLiquidationPriceMultiplier,
            "makerSide": sideName(for: metadata.makerSide),
            "minerCostInSatoshis": metadata.minerCostInSatoshis,
            "nominalUnits": metadata.nominalUnits,
            "startPrice": metadata.startPrice,
            "startingOracleMessage": metadata.startingOracleMessageHex,
            "startingOracleSignature": metadata.startingOracleSignatureHex,
            "takerSide": sideName(for: metadata.takerSide)
        ]
    }

    private static func fundingDictionary(
        for funding: OpalHedgeCoreContractFunding
    ) -> [String: Any] {
        var dictionary: [String: Any] = [
            "fundingOutputIndex": funding.fundingOutputIndex,
            "fundingSatoshis": funding.fundingSatoshis,
            "fundingTransactionHash": funding.fundingTransactionHash
        ]

        if let settlement = funding.settlement {
            dictionary["settlement"] = settlementDictionary(for: settlement)
        }

        return dictionary
    }

    private static func settlementDictionary(
        for settlement: OpalHedgeCoreContractSettlement
    ) -> [String: Any] {
        let payoutAmounts = settlement.payoutAmounts
        var dictionary: [String: Any] = [
            "hedgePayoutInSatoshis": payoutAmounts.shortPayoutInSatoshis,
            "longPayoutInSatoshis": payoutAmounts.longPayoutInSatoshis,
            "settlementTransactionHash": settlement.settlementTransactionHash,
            "settlementType": settlement.kind.rawValue
        ]

        if let settlementMessageHex = settlement.settlementMessageHex {
            dictionary["settlementMessage"] = settlementMessageHex
        }
        if let settlementSignatureHex = settlement.settlementSignatureHex {
            dictionary["settlementSignature"] = settlementSignatureHex
        }
        if let previousMessageHex = settlement.previousMessageHex {
            dictionary["previousMessage"] = previousMessageHex
        }
        if let previousSignatureHex = settlement.previousSignatureHex {
            dictionary["previousSignature"] = previousSignatureHex
        }
        if let settlementPrice = settlement.settlementPrice {
            dictionary["settlementPrice"] = settlementPrice
        }

        return dictionary
    }

    private static func feeDictionary(
        for feeData: OpalHedgeCoreContractFeeData
    ) -> [String: Any] {
        [
            "address": feeData.address,
            "description": feeData.description,
            "name": feeData.name,
            "satoshis": feeData.satoshis
        ]
    }

    private static func sideName(for side: OpalHedgeCoreContractSide) -> String {
        switch side {
        case .short:
            "Hedge"
        case .long:
            "Long"
        }
    }
}
