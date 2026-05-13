// OpalHedgeCoreContractDataDocumentValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentValidator {
    @Test("Creates deterministic contract data document")
    func createDeterministicContractDataDocument() throws {
        let draftData = try makeDraftData()
        let firstDocument = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let secondDocument = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )

        #expect(firstDocument == secondDocument)
        #expect(firstDocument.jsonText == secondDocument.jsonText)
        #expect(String(decoding: firstDocument.utf8Data, as: UTF8.self) == firstDocument.jsonText)
    }

    @Test("Matches golden contract data document")
    func matchGoldenContractDataDocument() throws {
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: makeDraftData()
        )

        #expect(document.jsonText == OpalHedgeFixtureData
            .upstreamHedgeTenWeekContractDataDocumentJsonText)
    }

    @Test("Uses AnyHedge hedge field names")
    func useAnyHedgeHedgeFieldNames() throws {
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: makeDraftData()
        )

        #expect(document.jsonText.contains("\"hedgePayoutAddress\""))
        #expect(document.jsonText.contains("\"hedgeInputInOracleUnits\""))
        #expect(document.jsonText.contains("\"hedgeInputInSatoshis\""))
        #expect(document.jsonText.contains("\"hedgeLockScript\""))
        #expect(document.jsonText.contains("\"hedgeMutualRedeemPublicKey\""))
        #expect(!document.jsonText.contains("short"))
    }

    @Test("Matches official AnyHedge metadata fields")
    func matchOfficialAnyHedgeMetadataFields() throws {
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: makeDraftData()
        )
        let dictionary = try documentDictionary(for: document)
        let metadata = try #require(dictionary["metadata"] as? [String: Any])

        #expect(Set(metadata.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractMetadataV1FieldNames)
    }

    @Test("Matches official AnyHedge funding fields")
    func matchOfficialAnyHedgeFundingFields() throws {
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049
                )
            ]
        )
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let dictionary = try documentDictionary(for: document)
        let fundings = try #require(dictionary["fundings"] as? [[String: Any]])
        let funding = try #require(fundings.first)

        #expect(Set(funding.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractFundingV1FieldNames)
    }

    @Test("Matches official AnyHedge automated payout fields")
    func matchOfficialAnyHedgeAutomatedPayoutFields() throws {
        let draftData = try makeDraftData(
            fundings: [fundingWithAutomatedPayout()]
        )
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let dictionary = try documentDictionary(for: document)
        let fundings = try #require(dictionary["fundings"] as? [[String: Any]])
        let funding = try #require(fundings.first)
        let settlement = try #require(funding["settlement"] as? [String: Any])

        #expect(Set(settlement.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractAutomatedPayoutV1FieldNames)
        #expect(settlement["hedgePayoutInSatoshis"] as? Int == 4_237_288)
        #expect(settlement["longPayoutInSatoshis"] as? Int == 1_412_429)
    }

    @Test("Omits absent AnyHedge automated payout optional fields")
    func omitAbsentAnyHedgeAutomatedPayoutOptionalFields() throws {
        let draftData = try makeDraftData(
            fundings: [fundingWithRequiredPayout()]
        )
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let dictionary = try documentDictionary(for: document)
        let fundings = try #require(dictionary["fundings"] as? [[String: Any]])
        let funding = try #require(fundings.first)
        let settlement = try #require(funding["settlement"] as? [String: Any])
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: document.jsonText
        )
        let decodedFunding = try #require(decodedDocument.draftData.fundings.first)
        let decodedSettlement = try #require(decodedFunding.settlement)

        #expect(Set(settlement.keys) == requiredSettlementFieldNames)
        #expect(!document.jsonText.contains("settlementMessage"))
        #expect(!document.jsonText.contains("settlementSignature"))
        #expect(!document.jsonText.contains("previousMessage"))
        #expect(!document.jsonText.contains("previousSignature"))
        #expect(!document.jsonText.contains("settlementPrice"))
        #expect(!document.jsonText.contains("null"))
        #expect(decodedSettlement.settlementMessageHex == nil)
        #expect(decodedSettlement.settlementSignatureHex == nil)
        #expect(decodedSettlement.previousMessageHex == nil)
        #expect(decodedSettlement.previousSignatureHex == nil)
        #expect(decodedSettlement.settlementPrice == nil)
    }

    @Test("Includes funding and fee arrays")
    func includeFundingAndFeeArrays() throws {
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049
                )
            ],
            fees: [
                OpalHedge.Core.ContractFeeData(
                    name: "settlement",
                    description: "Settlement service fee",
                    address: OpalHedgeFixtureData.longPayoutAddress,
                    satoshis: 1_000
                )
            ]
        )
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )

        #expect(document.jsonText.contains("\"fundingTransactionHash\""))
        #expect(document.jsonText.contains("\"fundings\""))
        #expect(document.jsonText.contains("\"fees\""))
        #expect(document.jsonText.contains("\"satoshis\":1000"))
    }

    @Test("Rejects non-finite metadata numbers when creating contract data document")
    func rejectNonFiniteMetadataNumbersWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData()
        let nonFiniteValues = [
            Double.nan,
            Double.infinity,
            -Double.infinity
        ]

        for fieldPath in metadataNumberFieldPaths {
            for value in nonFiniteValues {
                let invalidDraftData = try makeDraftData(
                    replacingMetadataNumberAt: fieldPath,
                    with: value,
                    in: draftData
                )
                let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                    _ = try OpalHedge.Core.ContractDataDocument(
                        draftData: invalidDraftData
                    )
                }

                OpalHedgeContractDataDocumentErrorExpectationTool.expectInvalidFieldType(
                    error,
                    at: fieldPath,
                    expectedFieldType: "finite number"
                )
            }
        }
    }

    @Test("Rejects start price drift when creating contract data document")
    func rejectStartPriceDriftWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData()
        let driftedMetadata = makeMetadata(
            from: draftData.metadata,
            startPrice: draftData.metadata.startPrice + 1
        )
        let invalidDraftData = OpalHedge.Core.ContractDraftData(
            parameters: draftData.parameters,
            metadata: driftedMetadata
        )

        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(
                draftData: invalidDraftData
            )
        }

        #expect(error == .inconsistentOracleMessageComponent(
            name: "startPrice",
            expected: draftData.metadata.startPrice,
            actual: draftData.metadata.startPrice + 1
        ))
    }

    private var metadataNumberFieldPaths: [OpalHedgeContractDataDocumentFieldPathData] {
        [
            .metadata("nominalUnits"),
            .metadata("lowLiquidationPriceMultiplier"),
            .metadata("highLiquidationPriceMultiplier"),
            .metadata("hedgeInputInOracleUnits"),
            .metadata("longInputInOracleUnits")
        ]
    }

    private var requiredSettlementFieldNames: Set<String> {
        [
            "hedgePayoutInSatoshis",
            "longPayoutInSatoshis",
            "settlementTransactionHash",
            "settlementType"
        ]
    }

    private func makeDraftData(
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

    private func makeDraftData(
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

    private func makeMetadata(
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

    private func makeMetadata(
        from metadata: OpalHedge.Core.ContractMetadata,
        startPrice: Int64? = nil,
        nominalUnits: Double? = nil,
        lowLiquidationPriceMultiplier: Double? = nil,
        highLiquidationPriceMultiplier: Double? = nil,
        shortInputInOracleUnits: Double? = nil,
        longInputInOracleUnits: Double? = nil
    ) -> OpalHedge.Core.ContractMetadata {
        OpalHedge.Core.ContractMetadata(
            takerSide: metadata.takerSide,
            makerSide: metadata.makerSide,
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
            minerCostInSatoshis: metadata.minerCostInSatoshis
        )
    }

    private func fundingWithRequiredPayout() -> OpalHedge.Core.ContractFunding {
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: .maturation,
            settlementTransactionHash: String(repeating: "2", count: 64),
            payoutAmounts: OpalHedge.Core.ContractSettlementPayoutAmounts(
                shortPayoutInSatoshis: 4_237_288,
                longPayoutInSatoshis: 1_412_429
            )
        )

        return OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 1,
            fundingSatoshis: 5_651_049,
            settlement: settlement
        )
    }

    private func fundingWithAutomatedPayout() -> OpalHedge.Core.ContractFunding {
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

        return OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 1,
            fundingSatoshis: 5_651_049,
            settlement: settlement
        )
    }

    private func documentDictionary(
        for document: OpalHedge.Core.ContractDataDocument
    ) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(
            with: document.utf8Data
        ) as? [String: Any])
    }
}
