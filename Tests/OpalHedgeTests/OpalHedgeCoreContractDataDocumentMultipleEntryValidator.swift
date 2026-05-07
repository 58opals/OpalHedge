// OpalHedgeCoreContractDataDocumentMultipleEntryValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentMultipleEntryValidator {
    @Test("Decodes multiple contract data document fundings and fees")
    func decodeMultipleContractDataDocumentFundingsAndFees() throws {
        let draftData = try makeDraftData()
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: document.jsonText
        )

        #expect(decodedDocument.draftData == draftData)
        #expect(decodedDocument.draftData.fundings.count == 2)
        #expect(decodedDocument.draftData.fees.count == 2)
        #expect(decodedDocument.draftData.fundings.map(\.fundingOutputIndex) == [0, 1])
        #expect(decodedDocument.draftData.fundings.map { $0.settlement != nil } == [false, true])
        #expect(decodedDocument.draftData.fees.map(\.name) == ["funding", "settlement"])
    }

    @Test("Round trips multiple contract data document fundings and fees")
    func roundTripMultipleContractDataDocumentFundingsAndFees() throws {
        let draftData = try makeDraftData()
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: document.jsonText
        )
        let encodedDocument = try OpalHedge.Core.ContractDataDocument(
            draftData: decodedDocument.draftData
        )

        #expect(encodedDocument.jsonText == document.jsonText)
        #expect(encodedDocument.draftData == document.draftData)
    }

    private func makeDraftData() throws -> OpalHedge.Core.ContractDraftData {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        return OpalHedge.Core.ContractDraftData(
            plan: plan,
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 0,
                    fundingSatoshis: 5_651_049
                ),
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "2", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049,
                    settlement: OpalHedge.Core.ContractSettlement(
                        kind: .maturation,
                        settlementTransactionHash: String(repeating: "3", count: 64),
                        shortPayoutInSatoshis: 4_237_288,
                        longPayoutInSatoshis: 1_412_429,
                        settlementMessageHex: OpalHedgeFixtureData.startingOracleMessageHex,
                        settlementSignatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
                        previousMessageHex: OpalHedgeFixtureData.startingOracleMessageHex,
                        previousSignatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
                        settlementPrice: 23_600
                    )
                )
            ],
            fees: [
                OpalHedge.Core.ContractFeeData(
                    name: "funding",
                    description: "Funding service fee",
                    address: OpalHedgeFixtureData.shortPayoutAddress,
                    satoshis: 500
                ),
                OpalHedge.Core.ContractFeeData(
                    name: "settlement",
                    description: "Settlement service fee",
                    address: OpalHedgeFixtureData.longPayoutAddress,
                    satoshis: 1_000
                )
            ]
        )
    }
}
