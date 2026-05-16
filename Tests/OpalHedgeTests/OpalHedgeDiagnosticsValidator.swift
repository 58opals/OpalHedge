// OpalHedgeDiagnosticsValidator.swift

import OpalDiagnostics
import OpalHedge
import OpalHedgeBitcoinCash
import Testing

@Suite(.serialized)
struct OpalHedgeDiagnosticsValidator {
    @Test("Public diagnostics catalog exposes stable filter values")
    func publicDiagnosticsCatalogExposesStableFilterValues() {
        let categories: [OpalDiagnostics.Category] = [
            OpalHedge.Diagnostics.Category.hedge,
            OpalHedge.Diagnostics.Category.contract,
            OpalHedge.Diagnostics.Category.dataDocument,
            OpalHedge.Diagnostics.Category.oracle,
            OpalHedge.Diagnostics.Category.bitcoinCash,
            OpalHedge.Diagnostics.Category.funding,
            OpalHedge.Diagnostics.Category.settlement
        ]

        #expect(categories.map(\.rawValue) == [
            "hedge",
            "hedge.contract",
            "hedge.data_document",
            "hedge.oracle",
            "hedge.bitcoin_cash",
            "hedge.funding",
            "hedge.settlement"
        ])
        #expect(OpalHedge.Diagnostics.Event.contractPlanCreated.rawValue == "opalhedge.contract.plan.created")
        #expect(OpalHedge.Diagnostics.Field.errorCode == "error_code")
        #expect(OpalHedge.Diagnostics.ErrorCode.transactionHashInvalid == "bitcoin_cash.transaction_hash.invalid")
    }

    @Test("Category filters support exact and hierarchical OpalHedge matching")
    func categoryFiltersSupportExactAndHierarchicalOpalHedgeMatching() {
        OpalDiagnostics.withConfiguration(
            .init(
                minimumLevel: .debug,
                categoryFilter: .enabled([OpalHedge.Diagnostics.Category.hedge]),
                bufferPolicy: .enabled(capacity: 10)
            )
        ) {
            OpalDiagnostics.logger(category: OpalHedge.Diagnostics.Category.hedge).record(
                event: "opalhedge.root",
                level: .debug
            )
            OpalDiagnostics.logger(category: OpalHedge.Diagnostics.Category.contract).record(
                event: OpalHedge.Diagnostics.Event.contractPlanCreated,
                level: .debug
            )

            #expect(OpalDiagnostics.recentRecords.map(\.category) == [OpalHedge.Diagnostics.Category.hedge])
        }

        OpalDiagnostics.withConfiguration(
            .init(
                minimumLevel: .debug,
                categoryFilter: .enabledIncludingSubcategories([OpalHedge.Diagnostics.Category.hedge]),
                bufferPolicy: .enabled(capacity: 10)
            )
        ) {
            OpalDiagnostics.logger(category: OpalHedge.Diagnostics.Category.contract).record(
                event: OpalHedge.Diagnostics.Event.contractPlanCreated,
                level: .debug
            )
            OpalDiagnostics.logger(category: OpalHedge.Diagnostics.Category.oracle).record(
                event: OpalHedge.Diagnostics.Event.oracleMessageParsed,
                level: .debug
            )
            OpalDiagnostics.logger(category: .fulcrum).record(
                event: "fulcrum.filtered",
                level: .debug
            )

            #expect(OpalDiagnostics.recentRecords.map(\.category) == [
                OpalHedge.Diagnostics.Category.contract,
                OpalHedge.Diagnostics.Category.oracle
            ])
        }
    }

    @Test("Data document diagnostics redact private error details")
    func dataDocumentDiagnosticsRedactPrivateErrorDetails() throws {
        try withDiagnosticsCapture {
            do {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: "not-json")
                Issue.record("Expected invalid JSON to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.dataDocumentDecodeFailed)
            )

            #expect(record.category == OpalHedge.Diagnostics.Category.dataDocument)
            #expect(findField(OpalHedge.Diagnostics.Field.errorCode, in: record)?.value == OpalHedge.Diagnostics.ErrorCode.dataDocumentInvalidJson)
            #expect(findField(OpalHedge.Diagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
            #expect(findField(OpalHedge.Diagnostics.Field.errorMessage, in: record)?.privacy == .private)
            #expect(record.fields.contains { $0.name == "error_type" } == false)
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
                findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.dataDocumentDecoded)
            )
            #expect(findField(OpalHedge.Diagnostics.Field.byteCount, in: record)?.value == String(paddedJSONText.utf8.count))
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
                findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.dataDocumentDecodeFailed)
            )
            #expect(record.category == OpalHedge.Diagnostics.Category.dataDocument)
            #expect(findField(OpalHedge.Diagnostics.Field.errorCode, in: record)?.value == OpalHedge.Diagnostics.ErrorCode.dataDocumentMissingField)
            #expect(findField(OpalHedge.Diagnostics.Field.byteCount, in: record)?.value == String(jsonText.utf8.count))
            #expect(findField(OpalHedge.Diagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
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
                findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.startingOracleProofVerificationFailed)
            )

            #expect(record.category == OpalHedge.Diagnostics.Category.oracle)
            #expect(findField(OpalHedge.Diagnostics.Field.errorCode, in: record)?.value == OpalHedge.Diagnostics.ErrorCode.oracleInvalidSignature)
            #expect(findField(OpalHedge.Diagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
            #expect(record.fields.contains { $0.name == "signature_hex" } == false)
            #expect(record.fields.contains { $0.name == "message_hex" } == false)
            #expect(record.fields.contains { $0.name == "public_key_hex" } == false)
        }
    }

    @Test("Oracle signature verification does not emit parser success diagnostics")
    func oracleSignatureVerificationDoesNotEmitParserSuccessDiagnostics() throws {
        try withDiagnosticsCapture {
            let message = try OpalHedge.Oracle.PriceMessage.parse(
                hex: OpalHedgeFixtureData.startingOracleMessageHex
            )
            OpalDiagnostics.clearRecentRecords()

            let isVerified = try OpalHedge.Oracle.SignatureVerifier.verify(
                message: message,
                signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
                publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
            )

            #expect(isVerified)
            #expect(findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.oracleSignatureVerified) != nil)
            #expect(findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.oracleMessageParsed) == nil)
        }
    }

    @Test("Oracle signature hex failures record signature diagnostics")
    func oracleSignatureHexFailuresRecordSignatureDiagnostics() throws {
        try withDiagnosticsCapture {
            let message = try OpalHedge.Oracle.PriceMessage.parse(
                hex: OpalHedgeFixtureData.startingOracleMessageHex
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
                findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.oracleSignatureVerificationFailed)
            )
            #expect(findField(OpalHedge.Diagnostics.Field.payloadType, in: record)?.value == "signature_hex")
            #expect(findField(OpalHedge.Diagnostics.Field.errorCategory, in: record)?.value == "oracle_signature")
            #expect(findField(OpalHedge.Diagnostics.Field.errorCode, in: record)?.value == OpalHedge.Diagnostics.ErrorCode.oracleInvalidHexCharacter)
            #expect(record.fields.contains { $0.name == "signature_hex" } == false)
            #expect(findField(OpalHedge.Diagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
        }
    }

    @Test("Contract validation records stable constraint diagnostics")
    func contractValidationRecordsStableConstraintDiagnostics() throws {
        try withDiagnosticsCapture {
            let context = OpalHedgeContractFixtureBuilder.makeCreationContext(
                lowLiquidationPriceMultiplier: 1
            )

            do {
                try OpalHedge.Core.ContractConstraintEvaluator.validateCreationContext(context)
                Issue.record("Expected invalid contract creation context to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(
                    named: OpalHedge.Diagnostics.Event.contractConstraintValidationFailed,
                    operation: "validate_creation_context"
                )
            )

            #expect(record.category == OpalHedge.Diagnostics.Category.contract)
            #expect(findField(OpalHedge.Diagnostics.Field.errorCode, in: record)?.value == OpalHedge.Diagnostics.ErrorCode.contractConstraintValidationFailed)
            #expect(findField(OpalHedge.Diagnostics.Field.constraintCategory, in: record)?.value == "parameters")
            #expect(findField(OpalHedge.Diagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
        }
    }

    @Test("Funding request diagnostics preserve core constraint error codes")
    func fundingRequestDiagnosticsPreserveCoreConstraintErrorCodes() throws {
        try withDiagnosticsCapture {
            let clientContext = OpalHedge.Client.Context()
            let plan = try OpalHedge.Core.ContractPlan(
                from: OpalHedgeContractFixtureBuilder.makeVerifiedCreationContext()
            )

            do {
                _ = try clientContext.createAnyHedgeContractFundingRequest(
                    from: plan,
                    network: .testnet
                )
                Issue.record("Expected network mismatch to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.fundingRequestCreationFailed)
            )
            #expect(record.category == OpalHedge.Diagnostics.Category.funding)
            #expect(findField(OpalHedge.Diagnostics.Field.errorCode, in: record)?.value == OpalHedge.Diagnostics.ErrorCode.contractConstraintValidationFailed)
            #expect(findField(OpalHedge.Diagnostics.Field.errorCategory, in: record)?.value == "constraint")
        }
    }

    @Test("Bitcoin Cash encoding and transaction hash failures record stable diagnostics")
    func bitcoinCashFailuresRecordStableDiagnostics() throws {
        try withDiagnosticsCapture {
            do {
                _ = try OpalHedgeBitcoinCashContractAddress(redeemScriptHex: "zz")
                Issue.record("Expected invalid redeem script hex to throw.")
            } catch {
            }

            let addressRecord = try #require(
                findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.contractAddressEncodingFailed)
            )
            #expect(addressRecord.category == OpalHedge.Diagnostics.Category.bitcoinCash)
            #expect(findField(OpalHedge.Diagnostics.Field.errorCode, in: addressRecord)?.value == OpalHedge.Diagnostics.ErrorCode.bitcoinCashInvalidRedeemScriptHex)
            #expect(findField(OpalHedge.Diagnostics.Field.errorMessage, in: addressRecord)?.value == "<redacted>")

            OpalDiagnostics.clearRecentRecords()

            let clientContext = OpalHedge.Client.Context()
            let plan = try OpalHedge.Core.ContractPlan(
                from: OpalHedgeContractFixtureBuilder.makeVerifiedCreationContext()
            )
            do {
                _ = try clientContext.createAnyHedgeContractFundingRecord(
                    from: plan,
                    fundingTransactionHash: "not-a-transaction-hash",
                    fundingOutputIndex: 0
                )
                Issue.record("Expected invalid funding transaction hash to throw.")
            } catch {
            }

            let hashRecord = try #require(
                findDiagnosticRecord(named: OpalHedge.Diagnostics.Event.transactionHashValidationFailed)
            )
            #expect(hashRecord.category == OpalHedge.Diagnostics.Category.bitcoinCash)
            #expect(findField(OpalHedge.Diagnostics.Field.errorCode, in: hashRecord)?.value == OpalHedge.Diagnostics.ErrorCode.transactionHashInvalid)
            #expect(hashRecord.fields.contains { $0.name == "transaction_hash" } == false)
            #expect(findField(OpalHedge.Diagnostics.Field.errorMessage, in: hashRecord)?.value == "<redacted>")
        }
    }

    private static let diagnosticsConfiguration = OpalDiagnostics.Configuration(
        minimumLevel: .debug,
        categoryFilter: .enabledIncludingSubcategories([OpalHedge.Diagnostics.Category.hedge]),
        bufferPolicy: .enabled(capacity: 10_000)
    )

    private func withDiagnosticsCapture<Success>(_ operation: () throws -> Success) rethrows -> Success {
        try OpalDiagnostics.withConfiguration(Self.diagnosticsConfiguration) {
            OpalDiagnostics.clearRecentRecords()
            return try operation()
        }
    }

    private func findDiagnosticRecord(
        named event: OpalDiagnostics.Event,
        operation: String? = nil
    ) -> OpalDiagnostics.Record? {
        OpalDiagnostics.recentRecords(matching: .init(event: event)).first { record in
            guard let operation else {
                return true
            }
            return findField(OpalHedge.Diagnostics.Field.operation, in: record)?.value == operation
        }
    }

    private func findField(_ name: String, in record: OpalDiagnostics.Record) -> OpalDiagnostics.Field? {
        record.fields.first { $0.name == name }
    }
}
