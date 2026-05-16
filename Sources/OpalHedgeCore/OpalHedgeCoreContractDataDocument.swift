// OpalHedgeCoreContractDataDocument.swift

import Foundation
import OpalDiagnostics

public struct OpalHedgeCoreContractDataDocument: Sendable, Equatable {
    public let draftData: OpalHedgeCoreContractDraftData
    public let jsonText: String

    public var utf8Data: Data {
        Data(jsonText.utf8)
    }

    public init(draftData: OpalHedgeCoreContractDraftData) throws {
        try self.init(
            draftData: draftData,
            diagnosticsOperation: "encode_data_document",
            successEvent: OpalHedgeCoreDiagnostics.Event.dataDocumentEncoded,
            failureEvent: OpalHedgeCoreDiagnostics.Event.dataDocumentEncodeFailed
        )
    }

    package init(
        draftData: OpalHedgeCoreContractDraftData,
        diagnosticsOperation: String,
        successEvent: OpalDiagnostics.Event,
        failureEvent: OpalDiagnostics.Event,
        diagnosticsByteCount: Int? = nil,
        extraFields: [OpalDiagnostics.Field] = []
    ) throws {
        do {
            try Self.validateDraftData(draftData)

            let data = try JSONSerialization.data(
                withJSONObject: Self.dictionary(for: draftData),
                options: [.sortedKeys]
            )

            self.draftData = draftData
            self.jsonText = String(decoding: data, as: UTF8.self)
            OpalHedgeCoreDiagnostics.record(
                successEvent,
                category: OpalHedgeCoreDiagnostics.Category.dataDocument,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField(diagnosticsOperation),
                    OpalHedgeCoreDiagnostics.moduleField("core"),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.fundingCount,
                        draftData.fundings.count
                    ),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.feeCount,
                        draftData.fees.count
                    ),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.byteCount,
                        diagnosticsByteCount ?? data.count
                    ),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.payloadType,
                        "json"
                    )
                ] + extraFields
            )
        } catch {
            OpalHedgeCoreDiagnostics.record(
                failureEvent,
                category: OpalHedgeCoreDiagnostics.Category.dataDocument,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField(diagnosticsOperation),
                    OpalHedgeCoreDiagnostics.moduleField("core"),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.fundingCount,
                        draftData.fundings.count
                    ),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.feeCount,
                        draftData.fees.count
                    ),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.payloadType,
                        "json"
                    )
                ] + extraFields + OpalHedgeCoreDiagnostics.makeConstraintFields(for: error)
                    + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func dictionary(
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

    private static func validateFiniteMetadataNumbers(
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

    private static func validateFiniteNumber(_ value: Double, name: String) throws {
        guard value.isFinite else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "finite number"
            )
        }
    }

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

    private static func validateFees(
        _ fees: [OpalHedgeCoreContractFeeData]
    ) throws {
        for (index, fee) in fees.enumerated() {
            _ = try OpalHedgeCoreContractConstraintEvaluator.validatePayoutAddress(
                fee.address,
                name: "fees[\(index)].address"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validateNonnegativeInteger(
                fee.satoshis,
                name: "fees[\(index)].satoshis"
            )
        }
    }

    private static func validateFundings(
        _ fundings: [OpalHedgeCoreContractFunding]
    ) throws {
        for (index, funding) in fundings.enumerated() {
            let fundingName = "fundings[\(index)]"
            try OpalHedgeCoreContractConstraintEvaluator.validateTransactionHashHex(
                funding.fundingTransactionHash,
                name: "\(fundingName).fundingTransactionHash"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validateNonnegativeInteger(
                funding.fundingOutputIndex,
                name: "\(fundingName).fundingOutputIndex"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validateNonnegativeInteger(
                funding.fundingSatoshis,
                name: "\(fundingName).fundingSatoshis"
            )

            guard let settlement = funding.settlement else {
                continue
            }

            let settlementName = "\(fundingName).settlement"
            try OpalHedgeCoreContractConstraintEvaluator.validateTransactionHashHex(
                settlement.settlementTransactionHash,
                name: "\(settlementName).settlementTransactionHash"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validateNonnegativeInteger(
                settlement.shortPayoutInSatoshis,
                name: "\(settlementName).hedgePayoutInSatoshis"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validateNonnegativeInteger(
                settlement.longPayoutInSatoshis,
                name: "\(settlementName).longPayoutInSatoshis"
            )
            try validateSettlementPayoutTotal(settlement)
            if let settlementPrice = settlement.settlementPrice {
                try OpalHedgeCoreContractConstraintEvaluator.validatePositiveInteger(
                    settlementPrice,
                    name: "\(settlementName).settlementPrice"
                )
            }
            if let settlementMessageHex = settlement.settlementMessageHex {
                try OpalHedgeCoreContractConstraintEvaluator.validateOracleMessageHex(
                    settlementMessageHex,
                    name: "\(settlementName).settlementMessage"
                )
            }
            if let settlementSignatureHex = settlement.settlementSignatureHex {
                try OpalHedgeCoreContractConstraintEvaluator.validateSchnorrSignatureHex(
                    settlementSignatureHex,
                    name: "\(settlementName).settlementSignature"
                )
            }
            if let previousMessageHex = settlement.previousMessageHex {
                try OpalHedgeCoreContractConstraintEvaluator.validateOracleMessageHex(
                    previousMessageHex,
                    name: "\(settlementName).previousMessage"
                )
            }
            if let previousSignatureHex = settlement.previousSignatureHex {
                try OpalHedgeCoreContractConstraintEvaluator.validateSchnorrSignatureHex(
                    previousSignatureHex,
                    name: "\(settlementName).previousSignature"
                )
            }
        }
    }

    private static func validateSettlementPayoutTotal(
        _ settlement: OpalHedgeCoreContractSettlement
    ) throws {
        let total = settlement.shortPayoutInSatoshis.addingReportingOverflow(
            settlement.longPayoutInSatoshis
        )
        guard !total.overflow else {
            throw OpalHedgeCoreContractConstraintError.contractSatoshisExceedMaximum(
                Int64.max
            )
        }
        guard total.partialValue <=
              OpalHedgeCoreContractConstraintPolicy.maxContractSatoshis else {
            throw OpalHedgeCoreContractConstraintError.contractSatoshisExceedMaximum(
                total.partialValue
            )
        }
    }

    private static func validateStartingOracleMetadata(
        _ metadata: OpalHedgeCoreContractMetadata,
        matches parameters: OpalHedgeCoreContractParameters
    ) throws {
        let startingOracleMessage = try OpalHedgeCoreContractOracleMessageData(
            hex: metadata.startingOracleMessageHex
        )
        _ = try OpalHedgeCoreContractOracleSignature(
            hex: metadata.startingOracleSignatureHex
        )

        guard metadata.startPrice == startingOracleMessage.priceValue else {
            throw OpalHedgeCoreContractConstraintError
                .inconsistentOracleMessageComponent(
                    name: "startPrice",
                    expected: startingOracleMessage.priceValue,
                    actual: metadata.startPrice
                )
        }
        guard parameters.startTimestamp == startingOracleMessage.messageTimestamp else {
            throw OpalHedgeCoreContractConstraintError
                .inconsistentOracleMessageComponent(
                    name: "startTimestamp",
                    expected: startingOracleMessage.messageTimestamp,
                    actual: parameters.startTimestamp
                )
        }
    }

    private static func validateMetadata(
        _ metadata: OpalHedgeCoreContractMetadata,
        matches parameters: OpalHedgeCoreContractParameters
    ) throws {
        guard metadata.makerSide != metadata.takerSide else {
            throw OpalHedgeCoreContractConstraintError.makerSideMustOpposeTaker(
                taker: metadata.takerSide,
                maker: metadata.makerSide
            )
        }

        let expectedDuration = parameters.maturityTimestamp - parameters.startTimestamp
        guard metadata.durationInSeconds == expectedDuration else {
            throw OpalHedgeCoreContractConstraintError
                .inconsistentOracleMessageComponent(
                    name: "durationInSeconds",
                    expected: expectedDuration,
                    actual: metadata.durationInSeconds
                )
        }

        try OpalHedgeCoreContractConstraintEvaluator.validatePayoutAddress(
            metadata.shortPayoutAddress,
            matches: parameters.shortLockScript,
            name: "shortPayoutAddress"
        )
        try OpalHedgeCoreContractConstraintEvaluator.validatePayoutAddress(
            metadata.longPayoutAddress,
            matches: parameters.longLockScript,
            name: "longPayoutAddress"
        )
    }
}
