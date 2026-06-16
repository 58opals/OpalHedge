// OpalHedgeCoreContractDataDocumentDecodeValidator~SettlementFieldShapes.swift

import Foundation
import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentDecodeValidator {
    @Test("Rejects invalid contract data document settlement field shapes")
    func rejectInvalidContractDataDocumentSettlementFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (.firstFundingSettlement("settlementType"), 1, "string"),
            (.firstFundingSettlement("settlementTransactionHash"), 1, "string"),
            (.firstFundingSettlement("hedgePayoutInSatoshis"), "4237288", "integer"),
            (.firstFundingSettlement("longPayoutInSatoshis"), "1412429", "integer"),
            (.firstFundingSettlement("settlementMessage"), 1, "string"),
            (.firstFundingSettlement("settlementSignature"), 1, "string"),
            (.firstFundingSettlement("previousMessage"), 1, "string"),
            (.firstFundingSettlement("previousSignature"), 1, "string"),
            (.firstFundingSettlement("settlementPrice"), "23600", "integer")
        ]
        let settledJsonText = try makeSettledContractDataDocumentJsonText()

        for fieldCase in cases {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldCase.fieldPath,
                with: fieldCase.fieldValue,
                in: settledJsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectInvalidFieldType(
                error,
                at: fieldCase.fieldPath,
                expectedFieldType: fieldCase.expectedFieldType
            )
        }
    }

    @Test("Rejects null contract data document settlement optional fields")
    func rejectNullContractDataDocumentSettlementOptionalFields() throws {
        let cases: [FieldShapeCase] = [
            (.firstFundingSettlement("settlementMessage"), NSNull(), "string"),
            (.firstFundingSettlement("settlementSignature"), NSNull(), "string"),
            (.firstFundingSettlement("previousMessage"), NSNull(), "string"),
            (.firstFundingSettlement("previousSignature"), NSNull(), "string"),
            (.firstFundingSettlement("settlementPrice"), NSNull(), "integer")
        ]
        let settledJsonText = try makeSettledContractDataDocumentJsonText()

        for fieldCase in cases {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldCase.fieldPath,
                with: fieldCase.fieldValue,
                in: settledJsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectInvalidFieldType(
                error,
                at: fieldCase.fieldPath,
                expectedFieldType: fieldCase.expectedFieldType
            )
        }
    }

    @Test("Rejects invalid contract data document side values")
    func rejectInvalidContractDataDocumentSideValues() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPathData] = [
            .metadata("takerSide"),
            .metadata("makerSide")
        ]

        for fieldPath in fieldPaths {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldPath,
                with: "Short",
                in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            #expect(error == .invalidContractSide("Short"))
        }
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
        let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
            _ = try OpalHedge.Core.ContractDataDocument(jsonText: invalidJsonText)
        }

        #expect(error == .invalidSettlementType("expired"))
    }
}
