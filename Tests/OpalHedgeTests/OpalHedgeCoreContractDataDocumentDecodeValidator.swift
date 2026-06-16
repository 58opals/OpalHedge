// OpalHedgeCoreContractDataDocumentDecodeValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentDecodeValidator {
    typealias FieldShapeCase = (
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
}
