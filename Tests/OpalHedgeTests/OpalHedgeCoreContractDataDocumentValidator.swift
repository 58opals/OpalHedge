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
        let dictionary = try makeDocumentDictionary(for: document)
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
        let dictionary = try makeDocumentDictionary(for: document)
        let fundings = try #require(dictionary["fundings"] as? [[String: Any]])
        let funding = try #require(fundings.first)

        #expect(Set(funding.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractFundingV1FieldNames)
    }

    @Test("Matches official AnyHedge automated payout fields")
    func matchOfficialAnyHedgeAutomatedPayoutFields() throws {
        let draftData = try makeDraftData(
            fundings: [makeFundingWithAutomatedPayout()]
        )
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let dictionary = try makeDocumentDictionary(for: document)
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
            fundings: [makeFundingWithRequiredPayout()]
        )
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let dictionary = try makeDocumentDictionary(for: document)
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
}
