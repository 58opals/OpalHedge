// OpalHedgeCoreContractDataDocumentDecodeValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentDecodeValidator {
    private typealias FieldShapeCase = (
        fieldPath: OpalHedgeContractDataDocumentFieldPathData,
        fieldValue: Any,
        expectedFieldType: String
    )

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

    @Test("Round trips golden contract data document")
    func roundTripGoldenContractDataDocument() throws {
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        )
        let encodedDocument = try OpalHedge.Core.ContractDataDocument(
            draftData: decodedDocument.draftData
        )
        let roundTripDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: encodedDocument.jsonText
        )

        #expect(encodedDocument.jsonText == OpalHedgeFixtureData
            .upstreamHedgeTenWeekContractDataDocumentJsonText)
        #expect(roundTripDocument.draftData == decodedDocument.draftData)
        #expect(roundTripDocument.jsonText == decodedDocument.jsonText)
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

    @Test("Rejects payout address and lock script drift when decoding")
    func rejectPayoutAddressAndLockScriptDriftWhenDecoding() throws {
        let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
            replacingFieldAt: .metadata("hedgePayoutAddress"),
            with: OpalHedgeFixtureData.longPayoutAddress,
            in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
        }

        #expect(
            error == .inconsistentPayoutAddressLockScript(
                name: "shortPayoutAddress",
                addressPublicKeyHashHex: "45f1f1c4a9b9419a5088a3e9c24a293d7a150e64",
                lockScriptPublicKeyHashHex: "285bb350881b21ac89724c6fb6dc914d096cd53b"
            )
        )
    }

    @Test("Rejects start price drift from starting oracle message when decoding")
    func rejectStartPriceDriftFromStartingOracleMessageWhenDecoding() throws {
        let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
            replacingFieldAt: .metadata("startPrice"),
            with: 23_601,
            in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
        }

        #expect(
            error == .inconsistentOracleMessageComponent(
                name: "startPrice",
                expected: 23_600,
                actual: 23_601
            )
        )
    }

    @Test("Rejects start timestamp drift from starting oracle message when decoding")
    func rejectStartTimestampDriftFromStartingOracleMessageWhenDecoding() throws {
        let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
            replacingFieldAt: .parameter("startTimestamp"),
            with: 615_644,
            in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
        }

        #expect(
            error == .inconsistentOracleMessageComponent(
                name: "startTimestamp",
                expected: 615_643,
                actual: 615_644
            )
        )
    }

    @Test("Rejects duration drift from contract timestamps when decoding")
    func rejectDurationDriftFromContractTimestampsWhenDecoding() throws {
        let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
            replacingFieldAt: .metadata("durationInSeconds"),
            with: 1,
            in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
        }

        #expect(
            error == .inconsistentOracleMessageComponent(
                name: "durationInSeconds",
                expected: 6_048_000,
                actual: 1
            )
        )
    }

    @Test("Rejects funding input drift when decoding")
    func rejectFundingInputDriftWhenDecoding() throws {
        let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
            replacingFieldAt: .metadata("longInputInSatoshis"),
            with: 1,
            in: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
        }

        #expect(
            error == .invalidContractFunding(
                shortInput: 4_237_288,
                longInput: 1,
                payoutSats: 5_649_717
            )
        )
    }

    @Test("Rejects invalid contract data document top-level field shapes")
    func rejectInvalidContractDataDocumentTopLevelFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (
                fieldPath: .topLevel("parameters"),
                fieldValue: [],
                expectedFieldType: "object"
            ),
            (
                fieldPath: .topLevel("metadata"),
                fieldValue: [],
                expectedFieldType: "object"
            ),
            (
                fieldPath: .topLevel("fundings"),
                fieldValue: [:],
                expectedFieldType: "array"
            ),
            (
                fieldPath: .topLevel("fees"),
                fieldValue: [:],
                expectedFieldType: "array"
            )
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
            (
                fieldPath: .topLevel("parameters"),
                fieldValue: NSNull(),
                expectedFieldType: "object"
            ),
            (
                fieldPath: .topLevel("metadata"),
                fieldValue: NSNull(),
                expectedFieldType: "object"
            ),
            (
                fieldPath: .topLevel("fundings"),
                fieldValue: NSNull(),
                expectedFieldType: "array"
            ),
            (
                fieldPath: .topLevel("fees"),
                fieldValue: NSNull(),
                expectedFieldType: "array"
            )
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
            (
                fieldPath: .topLevel("fundings"),
                fieldValue: [1],
                expectedFieldType: "object"
            ),
            (
                fieldPath: .topLevel("fees"),
                fieldValue: [1],
                expectedFieldType: "object"
            )
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

    @Test("Rejects invalid contract data document parameter field shapes")
    func rejectInvalidContractDataDocumentParameterFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (
                fieldPath: .parameter("oraclePublicKey"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .parameter("lowLiquidationPrice"),
                fieldValue: "11400",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .parameter("highLiquidationPrice"),
                fieldValue: "23600",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .parameter("startTimestamp"),
                fieldValue: "1700000000",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .parameter("maturityTimestamp"),
                fieldValue: "1706048000",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .parameter("nominalUnitsXSatsPerBch"),
                fieldValue: "13500",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .parameter("satsForNominalUnitsAtHighLiquidation"),
                fieldValue: "0",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .parameter("payoutSats"),
                fieldValue: "5649717",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .parameter("hedgeLockScript"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .parameter("longLockScript"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .parameter("enableMutualRedemption"),
                fieldValue: "1",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .parameter("hedgeMutualRedeemPublicKey"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .parameter("longMutualRedeemPublicKey"),
                fieldValue: 1,
                expectedFieldType: "string"
            )
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

    @Test("Rejects invalid contract data document metadata field shapes")
    func rejectInvalidContractDataDocumentMetadataFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (
                fieldPath: .metadata("startingOracleMessage"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .metadata("startingOracleSignature"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .metadata("takerSide"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .metadata("makerSide"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .metadata("hedgePayoutAddress"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .metadata("longPayoutAddress"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .metadata("startPrice"),
                fieldValue: "23600",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .metadata("durationInSeconds"),
                fieldValue: "6048000",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .metadata("nominalUnits"),
                fieldValue: "240.0",
                expectedFieldType: "number"
            ),
            (
                fieldPath: .metadata("lowLiquidationPriceMultiplier"),
                fieldValue: "0.75",
                expectedFieldType: "number"
            ),
            (
                fieldPath: .metadata("highLiquidationPriceMultiplier"),
                fieldValue: "1.25",
                expectedFieldType: "number"
            ),
            (
                fieldPath: .metadata("hedgeInputInOracleUnits"),
                fieldValue: "240.0",
                expectedFieldType: "number"
            ),
            (
                fieldPath: .metadata("longInputInOracleUnits"),
                fieldValue: "60.0",
                expectedFieldType: "number"
            ),
            (
                fieldPath: .metadata("hedgeInputInSatoshis"),
                fieldValue: "4237288",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .metadata("longInputInSatoshis"),
                fieldValue: "1412429",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .metadata("minerCostInSatoshis"),
                fieldValue: "1332",
                expectedFieldType: "integer"
            )
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

    @Test("Rejects decimal JSON numbers for contract data document integer fields")
    func rejectDecimalJsonNumbersForContractDataDocumentIntegerFields() throws {
        try rejectInvalidContractDataDocumentIntegerFields(replacingWith: 1.5)
    }

    @Test("Rejects boolean JSON values for contract data document integer fields")
    func rejectBooleanJsonValuesForContractDataDocumentIntegerFields() throws {
        try rejectInvalidContractDataDocumentIntegerFields(replacingWith: true)
    }

    @Test("Rejects out-of-range JSON numbers for contract data document integer fields")
    func rejectOutOfRangeJsonNumbersForContractDataDocumentIntegerFields() throws {
        try rejectInvalidContractDataDocumentIntegerFields(
            replacingWithRawJSONValue: "9223372036854775808"
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

    @Test("Rejects invalid contract data document funding field shapes")
    func rejectInvalidContractDataDocumentFundingFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (
                fieldPath: .firstFunding("fundingTransactionHash"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFunding("fundingOutputIndex"),
                fieldValue: "1",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .firstFunding("fundingSatoshis"),
                fieldValue: "5651049",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .firstFunding("settlement"),
                fieldValue: [],
                expectedFieldType: "object"
            )
        ]
        let settledJsonText = try settledContractDataDocumentJsonText()

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
            (
                fieldPath: .firstFee("name"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFee("description"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFee("address"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFee("satoshis"),
                fieldValue: "1000",
                expectedFieldType: "integer"
            )
        ]
        let settledJsonText = try settledContractDataDocumentJsonText()

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

    @Test("Rejects invalid contract data document settlement field shapes")
    func rejectInvalidContractDataDocumentSettlementFieldShapes() throws {
        let cases: [FieldShapeCase] = [
            (
                fieldPath: .firstFundingSettlement("settlementType"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("settlementTransactionHash"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("hedgePayoutInSatoshis"),
                fieldValue: "4237288",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .firstFundingSettlement("longPayoutInSatoshis"),
                fieldValue: "1412429",
                expectedFieldType: "integer"
            ),
            (
                fieldPath: .firstFundingSettlement("settlementMessage"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("settlementSignature"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("previousMessage"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("previousSignature"),
                fieldValue: 1,
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("settlementPrice"),
                fieldValue: "23600",
                expectedFieldType: "integer"
            )
        ]
        let settledJsonText = try settledContractDataDocumentJsonText()

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
            (
                fieldPath: .firstFundingSettlement("settlementMessage"),
                fieldValue: NSNull(),
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("settlementSignature"),
                fieldValue: NSNull(),
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("previousMessage"),
                fieldValue: NSNull(),
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("previousSignature"),
                fieldValue: NSNull(),
                expectedFieldType: "string"
            ),
            (
                fieldPath: .firstFundingSettlement("settlementPrice"),
                fieldValue: NSNull(),
                expectedFieldType: "integer"
            )
        ]
        let settledJsonText = try settledContractDataDocumentJsonText()

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

    private func rejectInvalidContractDataDocumentIntegerFields(
        replacingWith fieldValue: Any
    ) throws {
        for fieldPath in integerFieldPaths {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldPath,
                with: fieldValue,
                in: try sourceJsonText(for: fieldPath)
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectInvalidFieldType(
                error,
                at: fieldPath,
                expectedFieldType: "integer"
            )
        }
    }

    private func rejectInvalidContractDataDocumentIntegerFields(
        replacingWithRawJSONValue rawJSONValue: String
    ) throws {
        for fieldPath in integerFieldPaths {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldPath,
                withRawJSONValue: rawJSONValue,
                in: try sourceJsonText(for: fieldPath)
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectInvalidFieldType(
                error,
                at: fieldPath,
                expectedFieldType: "integer"
            )
        }
    }

    private var integerFieldPaths: [OpalHedgeContractDataDocumentFieldPathData] {
        [
            .parameter("lowLiquidationPrice"),
            .parameter("highLiquidationPrice"),
            .parameter("startTimestamp"),
            .parameter("maturityTimestamp"),
            .parameter("nominalUnitsXSatsPerBch"),
            .parameter("satsForNominalUnitsAtHighLiquidation"),
            .parameter("payoutSats"),
            .parameter("enableMutualRedemption"),
            .metadata("startPrice"),
            .metadata("durationInSeconds"),
            .metadata("hedgeInputInSatoshis"),
            .metadata("longInputInSatoshis"),
            .metadata("minerCostInSatoshis"),
            .firstFunding("fundingOutputIndex"),
            .firstFunding("fundingSatoshis"),
            .firstFee("satoshis"),
            .firstFundingSettlement("hedgePayoutInSatoshis"),
            .firstFundingSettlement("longPayoutInSatoshis"),
            .firstFundingSettlement("settlementPrice")
        ]
    }

    private var numberFieldPaths: [OpalHedgeContractDataDocumentFieldPathData] {
        [
            .metadata("nominalUnits"),
            .metadata("lowLiquidationPriceMultiplier"),
            .metadata("highLiquidationPriceMultiplier"),
            .metadata("hedgeInputInOracleUnits"),
            .metadata("longInputInOracleUnits")
        ]
    }

    private func sourceJsonText(
        for fieldPath: OpalHedgeContractDataDocumentFieldPathData
    ) throws -> String {
        switch fieldPath {
        case .firstFunding,
            .firstFee,
            .firstFundingSettlement:
            return try settledContractDataDocumentJsonText()
        default:
            return OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        }
    }

    private func settledContractDataDocumentJsonText() throws -> String {
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: makeSettledDraftData()
        )

        return document.jsonText
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
