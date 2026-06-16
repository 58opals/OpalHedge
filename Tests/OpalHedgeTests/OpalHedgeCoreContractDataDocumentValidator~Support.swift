// OpalHedgeCoreContractDataDocumentValidator~Support.swift

import Foundation
import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentValidator {
    var metadataNumberFieldPaths: [OpalHedgeContractDataDocumentFieldPathData] {
        [
            .metadata("nominalUnits"),
            .metadata("lowLiquidationPriceMultiplier"),
            .metadata("highLiquidationPriceMultiplier"),
            .metadata("hedgeInputInOracleUnits"),
            .metadata("longInputInOracleUnits")
        ]
    }

    var requiredSettlementFieldNames: Set<String> {
        [
            "hedgePayoutInSatoshis",
            "longPayoutInSatoshis",
            "settlementTransactionHash",
            "settlementType"
        ]
    }

    func makeDraftData(
        fundings: [OpalHedge.Core.ContractFunding] = [],
        fees: [OpalHedge.Core.ContractFeeData] = []
    ) throws -> OpalHedge.Core.ContractDraftData {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        return OpalHedge.Core.ContractDraftData(
            plan: plan,
            fundings: fundings,
            fees: fees
        )
    }

    func makeDraftData(
        replacingMetadataNumberAt fieldPath: OpalHedgeContractDataDocumentFieldPathData,
        with value: Double,
        in draftData: OpalHedge.Core.ContractDraftData
    ) throws -> OpalHedge.Core.ContractDraftData {
        let metadata = try makeMetadata(
            replacingNumberAt: fieldPath,
            with: value,
            in: draftData.metadata
        )

        return OpalHedge.Core.ContractDraftData(
            parameters: draftData.parameters,
            metadata: metadata,
            fundings: draftData.fundings,
            fees: draftData.fees
        )
    }

    func makeMetadata(
        replacingNumberAt fieldPath: OpalHedgeContractDataDocumentFieldPathData,
        with value: Double,
        in metadata: OpalHedge.Core.ContractMetadata
    ) throws -> OpalHedge.Core.ContractMetadata {
        switch fieldPath {
        case .metadata("nominalUnits"):
            return makeMetadata(from: metadata, nominalUnits: value)
        case .metadata("lowLiquidationPriceMultiplier"):
            return makeMetadata(from: metadata, lowLiquidationPriceMultiplier: value)
        case .metadata("highLiquidationPriceMultiplier"):
            return makeMetadata(from: metadata, highLiquidationPriceMultiplier: value)
        case .metadata("hedgeInputInOracleUnits"):
            return makeMetadata(from: metadata, shortInputInOracleUnits: value)
        case .metadata("longInputInOracleUnits"):
            return makeMetadata(from: metadata, longInputInOracleUnits: value)
        default:
            try #require(Bool(false))
            return metadata
        }
    }

    func makeMetadata(
        from metadata: OpalHedge.Core.ContractMetadata,
        takerSide: OpalHedge.Core.ContractSide? = nil,
        makerSide: OpalHedge.Core.ContractSide? = nil,
        startPrice: Int64? = nil,
        nominalUnits: Double? = nil,
        lowLiquidationPriceMultiplier: Double? = nil,
        highLiquidationPriceMultiplier: Double? = nil,
        shortInputInOracleUnits: Double? = nil,
        longInputInOracleUnits: Double? = nil,
        minerCostInSatoshis: Int64? = nil
    ) -> OpalHedge.Core.ContractMetadata {
        OpalHedge.Core.ContractMetadata(
            takerSide: takerSide ?? metadata.takerSide,
            makerSide: makerSide ?? metadata.makerSide,
            shortPayoutAddress: metadata.shortPayoutAddress,
            longPayoutAddress: metadata.longPayoutAddress,
            startingOracleMessageHex: metadata.startingOracleMessageHex,
            startingOracleSignatureHex: metadata.startingOracleSignatureHex,
            startPrice: startPrice ?? metadata.startPrice,
            durationInSeconds: metadata.durationInSeconds,
            nominalUnits: nominalUnits ?? metadata.nominalUnits,
            lowLiquidationPriceMultiplier: lowLiquidationPriceMultiplier
                ?? metadata.lowLiquidationPriceMultiplier,
            highLiquidationPriceMultiplier: highLiquidationPriceMultiplier
                ?? metadata.highLiquidationPriceMultiplier,
            isSimpleHedge: metadata.isSimpleHedge,
            shortInputInOracleUnits: shortInputInOracleUnits
                ?? metadata.shortInputInOracleUnits,
            longInputInOracleUnits: longInputInOracleUnits
                ?? metadata.longInputInOracleUnits,
            shortInputInSatoshis: metadata.shortInputInSatoshis,
            longInputInSatoshis: metadata.longInputInSatoshis,
            minerCostInSatoshis: minerCostInSatoshis ?? metadata.minerCostInSatoshis
        )
    }

    func makeFundingWithRequiredPayout() -> OpalHedge.Core.ContractFunding {
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: .maturation,
            settlementTransactionHash: String(repeating: "2", count: 64),
            payoutAmounts: OpalHedge.Core.ContractSettlementPayoutAmounts(
                shortPayoutInSatoshis: 4_237_288,
                longPayoutInSatoshis: 1_412_429
            )
        )

        return makeFunding(settlement: settlement)
    }

    func makeFundingWithAutomatedPayout() -> OpalHedge.Core.ContractFunding {
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: .maturation,
            settlementTransactionHash: String(repeating: "2", count: 64),
            payoutAmounts: OpalHedge.Core.ContractSettlementPayoutAmounts(
                shortPayoutInSatoshis: 4_237_288,
                longPayoutInSatoshis: 1_412_429
            ),
            settlementMessageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            settlementSignatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            previousMessageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            previousSignatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            settlementPrice: 23_600
        )

        return makeFunding(settlement: settlement)
    }

    func makeFunding(
        settlement: OpalHedge.Core.ContractSettlement
    ) -> OpalHedge.Core.ContractFunding {
        OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 1,
            fundingSatoshis: 5_651_049,
            settlement: settlement
        )
    }

    func makeDocumentDictionary(
        for document: OpalHedge.Core.ContractDataDocument
    ) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(
            with: document.utf8Data
        ) as? [String: Any])
    }
}
