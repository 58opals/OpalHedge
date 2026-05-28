// OpalHedgeCoreContractDataDocumentUnknownFieldValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentUnknownFieldValidator {
    @Test("Ignores unknown contract data document top-level fields")
    func ignoreUnknownContractDataDocumentTopLevelFields() throws {
        let referenceDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        )
        let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
            replacingTopLevelField: "futureExtension",
            with: ["value": "ignored"],
            in: referenceDocument.jsonText
        )
        let document = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)

        #expect(document.draftData == referenceDocument.draftData)
        #expect(document.jsonText == referenceDocument.jsonText)
    }

    @Test("Ignores unknown contract data document object fields")
    func ignoreUnknownContractDataDocumentObjectFields() throws {
        let referenceDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        )
        let cases = [
            (objectName: "parameters", fieldName: "futureParameter"),
            (objectName: "metadata", fieldName: "futureMetadata")
        ]

        for fieldCase in cases {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingField: fieldCase.fieldName,
                inTopLevelObject: fieldCase.objectName,
                with: "ignored",
                in: referenceDocument.jsonText
            )
            let document = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)

            #expect(document.draftData == referenceDocument.draftData)
            #expect(document.jsonText == referenceDocument.jsonText)
        }
    }

    @Test("Ignores unknown contract data document funding and fee fields")
    func ignoreUnknownContractDataDocumentFundingAndFeeFields() throws {
        let referenceDocument = try makeSettledContractDataDocument()
        let cases = [
            (arrayName: "fundings", fieldName: "futureFunding"),
            (arrayName: "fees", fieldName: "futureFee")
        ]

        for fieldCase in cases {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingField: fieldCase.fieldName,
                inFirstElementOf: fieldCase.arrayName,
                with: "ignored",
                in: referenceDocument.jsonText
            )
            let document = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)

            #expect(document.draftData == referenceDocument.draftData)
            #expect(document.jsonText == referenceDocument.jsonText)
        }
    }

    @Test("Ignores unknown contract data document settlement fields")
    func ignoreUnknownContractDataDocumentSettlementFields() throws {
        let referenceDocument = try makeSettledContractDataDocument()
        let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
            replacingSettlementField: "futureSettlement",
            with: "ignored",
            in: referenceDocument.jsonText
        )
        let document = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)

        #expect(document.draftData == referenceDocument.draftData)
        #expect(document.jsonText == referenceDocument.jsonText)
    }

    private func makeSettledContractDataDocument() throws -> OpalHedge.Core.ContractDataDocument {
        try OpalHedge.Core.ContractDataDocument(
            draftData: makeSettledDraftData()
        )
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
