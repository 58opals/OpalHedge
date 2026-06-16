// OpalHedgeCoreContractDataDocumentMissingFieldValidator~Support.swift

import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentMissingFieldValidator {
    func expectMissingOptionalSettlementField(
        _ fieldName: String,
        in settlement: OpalHedge.Core.ContractSettlement
    ) throws {
        switch fieldName {
        case "settlementMessage":
            #expect(settlement.settlementMessageHex == nil)
        case "settlementSignature":
            #expect(settlement.settlementSignatureHex == nil)
        case "previousMessage":
            #expect(settlement.previousMessageHex == nil)
        case "previousSignature":
            #expect(settlement.previousSignatureHex == nil)
        case "settlementPrice":
            #expect(settlement.settlementPrice == nil)
        default:
            try #require(Bool(false))
        }
    }

    func settledContractDataDocumentJsonText() throws -> String {
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: makeSettledDraftData()
        )

        return document.jsonText
    }

    func makeSettledDraftData() throws -> OpalHedge.Core.ContractDraftData {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        return OpalHedge.Core.ContractDraftData(
            plan: plan,
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049,
                    settlement: OpalHedge.Core.ContractSettlement(
                        kind: .maturation,
                        settlementTransactionHash: String(repeating: "2", count: 64),
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
                    name: "settlement",
                    description: "Settlement service fee",
                    address: OpalHedgeFixtureData.longPayoutAddress,
                    satoshis: 1_000
                )
            ]
        )
    }
}
