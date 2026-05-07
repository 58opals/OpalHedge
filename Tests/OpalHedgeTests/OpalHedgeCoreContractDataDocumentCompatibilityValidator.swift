// OpalHedgeCoreContractDataDocumentCompatibilityValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentCompatibilityValidator {
    @Test("Matches AnyHedge settled contract data document field families")
    func matchAnyHedgeSettledContractDataDocumentFieldFamilies() throws {
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: makeSettledDraftData()
        )
        let dictionary = try documentDictionary(for: document)
        let metadata = try #require(dictionary["metadata"] as? [String: Any])
        let fundings = try #require(dictionary["fundings"] as? [[String: Any]])
        let funding = try #require(fundings.first)
        let settlement = try #require(funding["settlement"] as? [String: Any])
        let fees = try #require(dictionary["fees"] as? [[String: Any]])
        let fee = try #require(fees.first)

        #expect(Set(dictionary.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractDataDocumentFieldNames)
        #expect(Set(metadata.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractMetadataV1FieldNames)
        #expect(Set(funding.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractFundingWithSettlementV1FieldNames)
        #expect(Set(settlement.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractAutomatedPayoutV1FieldNames)
        #expect(Set(fee.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractFeeFieldNames)
    }

    private func makeSettledDraftData() throws -> OpalHedge.Core.ContractDraftData {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        return OpalHedge.Core.ContractDraftData(
            plan: plan,
            fundings: [fundingWithAutomatedPayout()],
            fees: [
                OpalHedge.Core.ContractFeeData(
                    name: "settlement",
                    description: "Settlement service fee",
                    address: OpalHedgeFixtureData.longPayoutAddress,
                    satoshis: 1_000
                )
            ]
        )
    }

    private func fundingWithAutomatedPayout() -> OpalHedge.Core.ContractFunding {
        OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 1,
            fundingSatoshis: 5_651_049,
            settlement: OpalHedge.Core.ContractSettlement(
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
