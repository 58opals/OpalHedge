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
                hex: OpalHedgeFixtureData.startingOracleMessageHex
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
                findDiagnosticRecord(named: OpalDiagnostics.Event.oracleSignatureVerificationFailed)
            )
            #expect(findField(OpalDiagnostics.Field.payloadType, in: record)?.value == "signature_hex")
            #expect(findField(OpalDiagnostics.Field.errorCategory, in: record)?.value == "oracle_signature")
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "oracle.invalid_hex_character")
            #expect(record.fields.contains { $0.name == "signature_hex" } == false)
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
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
                    named: OpalDiagnostics.Event.contractConstraintValidationFailed,
                    operation: "validate_creation_context"
                )
            )

            #expect(record.category == OpalDiagnostics.Category.contract)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "contract.constraint_validation_failed")
            #expect(findField(OpalDiagnostics.Field.constraintCategory, in: record)?.value == "parameters")
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
        }
    }

    @Test("Core settlement diagnostics use stable settlement category")
    func coreSettlementDiagnosticsUseStableSettlementCategory() throws {
        try withDiagnosticsCapture {
            do {
                _ = try OpalHedge.Core.SettlementCalculator.calculateOutcome(
                    parameters: OpalHedgeFixtureData.contractParameters,
                    fundingSatoshis: 1,
                    redeemPrice: 23_500
                )
                Issue.record("Expected underfunded settlement calculation to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.settlementPayoutCalculationFailed)
            )
            #expect(record.category == OpalDiagnostics.Category.settlement)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "settlement.payout_invalid")
            #expect(findField(OpalDiagnostics.Field.errorCategory, in: record)?.value == "settlement")
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
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
                findDiagnosticRecord(named: OpalDiagnostics.Event.fundingRequestCreationFailed)
            )
            #expect(record.category == OpalDiagnostics.Category.funding)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "contract.constraint_validation_failed")
            #expect(findField(OpalDiagnostics.Field.errorCategory, in: record)?.value == "constraint")
        }
    }

    @Test("Funding output failures record stable diagnostics")
    func fundingOutputFailuresRecordStableDiagnostics() throws {
        try withDiagnosticsCapture {
            let validPlan = try OpalHedge.Core.ContractPlan(
                from: OpalHedgeContractFixtureBuilder.makeVerifiedCreationContext()
            )
            let parameters = validPlan.parameters
            let invalidParameters = OpalHedge.Core.ContractParameters(
                oraclePublicKey: parameters.oraclePublicKey,
                lowLiquidationPrice: parameters.lowLiquidationPrice,
                highLiquidationPrice: parameters.highLiquidationPrice,
                startTimestamp: parameters.startTimestamp,
                maturityTimestamp: parameters.maturityTimestamp,
                nominalUnitsXSatsPerBch: parameters.nominalUnitsXSatsPerBch,
                satsForNominalUnitsAtHighLiquidation: parameters.satsForNominalUnitsAtHighLiquidation,
                payoutSats: Int64.max,
                shortLockScript: parameters.shortLockScript,
                longLockScript: parameters.longLockScript,
                enableMutualRedemption: parameters.enableMutualRedemption,
                shortMutualRedeemPublicKey: parameters.shortMutualRedeemPublicKey,
                longMutualRedeemPublicKey: parameters.longMutualRedeemPublicKey
            )
            let invalidPlan = OpalHedge.Core.ContractPlan(
                parameters: invalidParameters,
                metadata: validPlan.metadata
            )
            OpalDiagnostics.clearRecentRecords()

            do {
                _ = try OpalHedgeBitcoinCashAnyHedgeContractBundle(plan: invalidPlan)
                Issue.record("Expected funding output overflow to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.fundingRequestCreationFailed)
            )
            #expect(record.category == OpalDiagnostics.Category.funding)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "funding.output.satoshis_overflow")
            #expect(findField(OpalDiagnostics.Field.errorCategory, in: record)?.value == "funding")
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
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
                findDiagnosticRecord(named: OpalDiagnostics.Event.contractAddressEncodingFailed)
            )
            #expect(addressRecord.category == OpalDiagnostics.Category.bitcoinCash)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: addressRecord)?.value == "bitcoin_cash.invalid_redeem_script_hex")
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: addressRecord)?.value == "<redacted>")

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
                findDiagnosticRecord(named: OpalDiagnostics.Event.transactionHashValidationFailed)
            )
            #expect(hashRecord.category == OpalDiagnostics.Category.bitcoinCash)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: hashRecord)?.value == "bitcoin_cash.transaction_hash.invalid")
            #expect(hashRecord.fields.contains { $0.name == "transaction_hash" } == false)
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: hashRecord)?.value == "<redacted>")
        }
    }

}
