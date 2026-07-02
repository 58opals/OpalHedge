// OpalHedgeCoreContractDataDocumentDecodeValidator~MetadataFieldShapes.swift

import Testing
import OpalHedge

struct InvalidIntegerJSONValueCase: Sendable, CustomStringConvertible {
    let description: String
    let rawJSONValue: String
}

extension OpalHedgeCoreContractDataDocumentDecodeValidator {
    @Test("Rejects invalid contract data document metadata field shapes")
    func rejectInvalidContractDataDocumentMetadataFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (.metadata("startingOracleMessage"), 1, "string"),
            (.metadata("startingOracleSignature"), 1, "string"),
            (.metadata("takerSide"), 1, "string"),
            (.metadata("makerSide"), 1, "string"),
            (.metadata("hedgePayoutAddress"), 1, "string"),
            (.metadata("longPayoutAddress"), 1, "string"),
            (.metadata("startPrice"), "23600", "integer"),
            (.metadata("durationInSeconds"), "6048000", "integer"),
            (.metadata("nominalUnits"), "240.0", "number"),
            (.metadata("lowLiquidationPriceMultiplier"), "0.75", "number"),
            (.metadata("highLiquidationPriceMultiplier"), "1.25", "number"),
            (.metadata("hedgeInputInOracleUnits"), "240.0", "number"),
            (.metadata("longInputInOracleUnits"), "60.0", "number"),
            (.metadata("hedgeInputInSatoshis"), "4237288", "integer"),
            (.metadata("longInputInSatoshis"), "1412429", "integer"),
            (.metadata("minerCostInSatoshis"), "1332", "integer")
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

    @Test(
        "Rejects invalid JSON values for contract data document integer fields",
        arguments: [
            InvalidIntegerJSONValueCase(
                description: "decimal JSON number",
                rawJSONValue: "1.5"
            ),
            InvalidIntegerJSONValueCase(
                description: "boolean JSON value",
                rawJSONValue: "true"
            ),
            InvalidIntegerJSONValueCase(
                description: "out-of-range JSON number",
                rawJSONValue: "9223372036854775808"
            )
        ]
    )
    func rejectInvalidJsonValuesForContractDataDocumentIntegerFields(
        _ invalidValue: InvalidIntegerJSONValueCase
    ) throws {
        try rejectInvalidContractDataDocumentIntegerFields(
            replacingWithRawJSONValue: invalidValue.rawJSONValue
        )
    }

    @Test("Rejects boolean JSON values for contract data document number fields")
    func rejectBooleanJsonValuesForContractDataDocumentNumberFields() throws {
        for fieldPath in numberFieldPaths {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldPath,
                with: true,
                in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectInvalidFieldType(
                error,
                at: fieldPath,
                expectedFieldType: "number"
            )
        }
    }
}
