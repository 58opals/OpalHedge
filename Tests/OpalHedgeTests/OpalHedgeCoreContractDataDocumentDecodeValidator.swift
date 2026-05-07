// OpalHedgeCoreContractDataDocumentDecodeValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentDecodeValidator {
    @Test("Decodes golden contract data document")
    func decodeGoldenContractDataDocument() throws {
        let document = try OpalHedge.Core.ContractDataDocument(
            jsonText: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        )
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        #expect(document.draftData.parameters == OpalHedgeFixtureData.contractParameters)
        #expect(document.draftData.metadata == plan.metadata)
        #expect(document.draftData.fundings.isEmpty)
        #expect(document.draftData.fees.isEmpty)
        #expect(document.jsonText == OpalHedgeFixtureData
            .upstreamHedgeTenWeekContractDataDocumentJsonText)
    }

    @Test("Decodes settled contract data document")
    func decodeSettledContractDataDocument() throws {
        let draftData = try makeSettledDraftData()
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            utf8Data: document.utf8Data
        )

        #expect(decodedDocument.draftData == draftData)
        #expect(decodedDocument.jsonText == document.jsonText)
    }

    @Test("Rejects missing contract data document field")
    func rejectMissingContractDataDocumentField() {
        let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
            _ = try OpalHedge.Core.ContractDataDocument(
                jsonText: #"{"fees":[],"fundings":[],"metadata":{}}"#
            )
        }

        #expect(error == .missingField("parameters"))
    }

    @Test("Rejects invalid contract data document settlement type")
    func rejectInvalidContractDataDocumentSettlementType() throws {
        let draftData = try makeSettledDraftData()
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: draftData
        )
        let invalidJsonText = document.jsonText.replacingOccurrences(
            of: #""settlementType":"maturation""#,
            with: #""settlementType":"expired""#
        )
        let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
            _ = try OpalHedge.Core.ContractDataDocument(jsonText: invalidJsonText)
        }

        #expect(error == .invalidSettlementType("expired"))
    }

    private func makeSettledDraftData() throws -> OpalHedge.Core.ContractDraftData {
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
