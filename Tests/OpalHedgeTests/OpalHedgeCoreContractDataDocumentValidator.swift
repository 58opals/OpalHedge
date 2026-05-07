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
