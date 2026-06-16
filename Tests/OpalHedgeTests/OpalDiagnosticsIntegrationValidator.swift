// OpalDiagnosticsIntegrationValidator.swift

import OpalDiagnostics
import OpalHedge
import OpalHedgeBitcoinCash
import Testing

@Suite(.serialized)
struct OpalDiagnosticsIntegrationValidator {
    @Test("Data document diagnostics redact private error details")
    func dataDocumentDiagnosticsRedactPrivateErrorDetails() throws {
        try withDiagnosticsCapture {
            do {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: "not-json")
                Issue.record("Expected invalid JSON to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.dataDocumentDecodeFailed)
            )

            #expect(record.category == OpalDiagnostics.Category.dataDocument)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "data_document.invalid_json")
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.privacy == .private)
            #expect(findField("error_type", in: record)?.value.contains("OpalHedgeCoreContractDataDocumentError") == true)
            #expect(record.fields.contains { $0.name == "raw_message" } == false)
            #expect(record.fields.contains { $0.name == "serialized_payload" } == false)
        }
    }

    @Test("Data document decode diagnostics report input byte count")
    func dataDocumentDecodeDiagnosticsReportInputByteCount() throws {
        try withDiagnosticsCapture {
            let compactDocument = try OpalHedge.Core.ContractDataDocument(
                draftData: OpalHedge.Core.ContractDraftData(
                    plan: OpalHedge.Core.ContractPlan(
                        from: OpalHedgeContractFixtureBuilder.makeVerifiedCreationContext()
                    )
                )
            )
            let paddedJSONText = "\n  \(compactDocument.jsonText)  \n"

            _ = try OpalHedge.Core.ContractDataDocument(jsonText: paddedJSONText)

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.dataDocumentDecoded)
            )
            #expect(findField(OpalDiagnostics.Field.byteCount, in: record)?.value == String(paddedJSONText.utf8.count))
        }
    }

    @Test("Data document decode validation failures report input byte count")
    func dataDocumentDecodeValidationFailuresReportInputByteCount() throws {
        try withDiagnosticsCapture {
            let plan = try OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
            let fundedDocument = try OpalHedge.Core.ContractDataDocument(
                draftData: OpalHedge.Core.ContractDraftData(
                    plan: plan,
                    fundings: [
                        OpalHedge.Core.ContractFunding(
                            fundingTransactionHash: String(repeating: "1", count: 64),
                            fundingOutputIndex: 0,
                            fundingSatoshis: 5_651_049
                        )
                    ]
                )
            )
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: .firstFunding("fundingTransactionHash"),
                with: "zz",
                in: fundedDocument.jsonText
            )
            OpalDiagnostics.clearRecentRecords()

            do {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
                Issue.record("Expected invalid funding transaction hash to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.dataDocumentDecodeFailed)
            )
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "contract.constraint_validation_failed")
            #expect(findField(OpalDiagnostics.Field.byteCount, in: record)?.value == String(jsonText.utf8.count))
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
        }
    }

    @Test("Data document semantic decode failures record diagnostics")
    func dataDocumentSemanticDecodeFailuresRecordDiagnostics() throws {
        try withDiagnosticsCapture {
            let jsonText = "{}"

            do {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
                Issue.record("Expected missing fields to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.dataDocumentDecodeFailed)
            )
            #expect(record.category == OpalDiagnostics.Category.dataDocument)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "data_document.missing_field")
            #expect(findField(OpalDiagnostics.Field.byteCount, in: record)?.value == String(jsonText.utf8.count))
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
        }
    }

    @Test("Oracle verification records stable failure diagnostics")
    func oracleVerificationRecordsStableFailureDiagnostics() throws {
        try withDiagnosticsCapture {
            do {
                _ = try OpalHedge.Oracle.verifyStartingPriceProof(
                    messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
                    signatureHex: String(repeating: "0", count: 128),
                    publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
                )
                Issue.record("Expected invalid oracle signature to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.startingOracleProofVerificationFailed)
            )

            #expect(record.category == OpalDiagnostics.Category.oracle)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "oracle.invalid_signature")
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
            #expect(record.fields.contains { $0.name == "signature_hex" } == false)
            #expect(record.fields.contains { $0.name == "message_hex" } == false)
            #expect(record.fields.contains { $0.name == "public_key_hex" } == false)
        }
    }

    @Test("Oracle signature verification does not emit parser success diagnostics")
    func oracleSignatureVerificationDoesNotEmitParserSuccessDiagnostics() throws {
        try withDiagnosticsCapture {
            let message = try OpalHedge.Oracle.PriceMessage.parse(
                rawHex: OpalHedgeFixtureData.startingOracleMessageHex
            )
            OpalDiagnostics.clearRecentRecords()

            let isVerified = try OpalHedge.Oracle.SignatureVerifier.verify(
                message: message,
                signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
                publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
            )

            #expect(isVerified)
            #expect(findDiagnosticRecord(named: OpalDiagnostics.Event.oracleSignatureVerified) != nil)
            #expect(findDiagnosticRecord(named: OpalDiagnostics.Event.oracleMessageParsed) == nil)
        }
    }

    @Test("Oracle signature invalid result emits shared error fields")
    func verifyOracleSignatureInvalidResultEmitsSharedErrorFields() throws {
        try withDiagnosticsCapture {
            let message = try OpalHedge.Oracle.PriceMessage.parse(
                rawHex: OpalHedgeFixtureData.startingOracleMessageHex
            )
            OpalDiagnostics.clearRecentRecords()

            let isVerified = try OpalHedge.Oracle.SignatureVerifier.verify(
                message: message,
                signatureHex: String(repeating: "0", count: 128),
                publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
            )

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.oracleSignatureVerificationFailed)
            )
            #expect(!isVerified)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "oracle.invalid_signature")
            #expect(findField(OpalDiagnostics.Field.errorCategory, in: record)?.value == "oracle_signature")
            #expect(findField("error_type", in: record)?.value.contains("OpalHedgeOracleSignatureVerificationError") == true)
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
        }
    }

    @Test("Oracle signature hex failures record signature diagnostics")
    func oracleSignatureHexFailuresRecordSignatureDiagnostics() throws {
        try withDiagnosticsCapture {
            let message = try OpalHedge.Oracle.PriceMessage.parse(
                rawHex: OpalHedgeFixtureData.startingOracleMessageHex
            )
            OpalDiagnostics.clearRecentRecords()

            do {
                _ = try OpalHedge.Oracle.SignatureVerifier.verify(
                    message: message,
                    signatureHex: "zz",
                    publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
                )
                Issue.record("Expected malformed signature hex to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.oracleSignatureVerificationFailed)
            )
            #expect(findField(OpalDiagnostics.Field.payloadType, in: record)?.value == "signature_hex")
            #expect(findField(OpalDiagnostics.Field.errorCategory, in: record)?.value == "oracle_signature")
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "oracle.invalid_hex_character")
            #expect(record.fields.contains { $0.name == "signature_hex" } == false)
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
        }
    }
}
