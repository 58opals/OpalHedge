// OpalHedgeCoreContractDataDocumentDecodeValidator~TopLevelFieldShapes.swift

import Foundation
import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentDecodeValidator {
    @Test("Rejects invalid contract data document top-level field shapes")
    func rejectInvalidContractDataDocumentTopLevelFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (.topLevel("parameters"), [], "object"),
            (.topLevel("metadata"), [], "object"),
            (.topLevel("fundings"), [:], "array"),
            (.topLevel("fees"), [:], "array")
        ]

        for fieldCase in cases {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldCase.fieldPath,
                with: fieldCase.fieldValue,
                in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
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

    @Test("Rejects null contract data document top-level fields")
    func rejectNullContractDataDocumentTopLevelFields() throws {
        let cases: [FieldShapeCase] = [
            (.topLevel("parameters"), NSNull(), "object"),
            (.topLevel("metadata"), NSNull(), "object"),
            (.topLevel("fundings"), NSNull(), "array"),
            (.topLevel("fees"), NSNull(), "array")
        ]

        for fieldCase in cases {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldCase.fieldPath,
                with: fieldCase.fieldValue,
                in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
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

    @Test("Rejects invalid contract data document array entry shapes")
    func rejectInvalidContractDataDocumentArrayEntryShapes() throws {
        let cases: [FieldShapeCase] = [
            (.topLevel("fundings"), [1], "object"),
            (.topLevel("fees"), [1], "object")
        ]

        for fieldCase in cases {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldCase.fieldPath,
                with: fieldCase.fieldValue,
                in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
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
