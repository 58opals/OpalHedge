// OpalHedgeCoreContractDataDocumentDecodeValidator~FundingFeeFieldShapes.swift

import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentDecodeValidator {
    @Test("Rejects invalid contract data document funding field shapes")
    func rejectInvalidContractDataDocumentFundingFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (.firstFunding("fundingTransactionHash"), 1, "string"),
            (.firstFunding("fundingOutputIndex"), "1", "integer"),
            (.firstFunding("fundingSatoshis"), "5651049", "integer"),
            (.firstFunding("settlement"), [], "object")
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

    @Test("Rejects invalid contract data document fee field shapes")
    func rejectInvalidContractDataDocumentFeeFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (.firstFee("name"), 1, "string"),
            (.firstFee("description"), 1, "string"),
            (.firstFee("address"), 1, "string"),
            (.firstFee("satoshis"), "1000", "integer")
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
}
