// OpalDiagnosticsIntegrationValidator~ContractAndFunding.swift

import OpalDiagnostics
import OpalHedge
import OpalHedgeBitcoinCash
import Testing

extension OpalDiagnosticsIntegrationValidator {
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
                Issue.record("Expected invalid funding output parameters to throw.")
            } catch {
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.fundingRequestCreationFailed)
            )
            #expect(record.category == OpalDiagnostics.Category.funding)
            #expect(findField(OpalDiagnostics.Field.errorCode, in: record)?.value == "bitcoin_cash.parameter.invalid_positive_integer")
            #expect(findField(OpalDiagnostics.Field.errorCategory, in: record)?.value == "bitcoin_cash")
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: record)?.value == "<redacted>")
        }
    }

    @Test("Bitcoin Cash encoding and transaction hash failures record stable diagnostics")
    func bitcoinCashFailuresRecordStableDiagnostics() throws {
        try withDiagnosticsCapture {
            do {
                _ = try OpalHedgeBitcoinCashContractAddress(rawRedeemScriptHex: "zz")
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
            #expect(findField(OpalDiagnostics.Field.errorCategory, in: hashRecord)?.value == "bitcoin_cash")
            #expect(hashRecord.fields.contains { $0.name == "transaction_hash" } == false)
            #expect(findField(OpalDiagnostics.Field.errorMessage, in: hashRecord)?.value == "<redacted>")
        }
    }
}
