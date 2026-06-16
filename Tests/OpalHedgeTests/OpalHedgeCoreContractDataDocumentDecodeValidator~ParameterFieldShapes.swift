// OpalHedgeCoreContractDataDocumentDecodeValidator~ParameterFieldShapes.swift

import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentDecodeValidator {
    @Test("Rejects invalid contract data document parameter field shapes")
    func rejectInvalidContractDataDocumentParameterFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (.parameter("oraclePublicKey"), 1, "string"),
            (.parameter("lowLiquidationPrice"), "11400", "integer"),
            (.parameter("highLiquidationPrice"), "23600", "integer"),
            (.parameter("startTimestamp"), "1700000000", "integer"),
            (.parameter("maturityTimestamp"), "1706048000", "integer"),
            (.parameter("nominalUnitsXSatsPerBch"), "13500", "integer"),
            (.parameter("satsForNominalUnitsAtHighLiquidation"), "0", "integer"),
            (.parameter("payoutSats"), "5649717", "integer"),
            (.parameter("hedgeLockScript"), 1, "string"),
            (.parameter("longLockScript"), 1, "string"),
            (.parameter("enableMutualRedemption"), "1", "integer"),
            (.parameter("hedgeMutualRedeemPublicKey"), 1, "string"),
            (.parameter("longMutualRedeemPublicKey"), 1, "string")
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
