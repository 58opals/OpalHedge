// OpalHedgeBitcoinCashAnyHedgeContractSettlementRequestValidator.swift

import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractSettlementRequestValidator {
    @Test("Creates AnyHedge maturation settlement request")
    func createAnyHedgeMaturationSettlementRequest() throws {
        let fundingRecord = try makeFundingRecord()
        let previousOracleProof = try OpalHedgeContractFixtureBuilder
            .makeStartingSettlementOracleProof()
        let settlementOracleProof = try OpalHedgeContractFixtureBuilder
            .makeSettlementOracleProof(
                messageTimestamp: 6_663_643,
                priceValue: 23_500
            )
        let request = try fundingRecord.createSettlementRequest(
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof
        )
        let directRequest = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementRequest(
            domainFundingRecord: fundingRecord,
            previousOracleDomainProof: previousOracleProof,
            settlementOracleDomainProof: settlementOracleProof
        )

        #expect(request == directRequest)
        #expect(request.domainFundingRecord == fundingRecord)
        #expect(request.fundingOutput == fundingRecord.fundingOutput)
        #expect(request.domainFunding == fundingRecord.funding)
        #expect(request.previousOracleDomainProof == previousOracleProof)
        #expect(request.settlementOracleDomainProof == settlementOracleProof)
        #expect(request.settlementCondition == .maturation)
        #expect(request.settlementKind == .maturation)
        #expect(request.settlementPrice == 23_500)
        #expect(
            request.settlementPayoutAmounts == OpalHedge.BitcoinCash
                .AnyHedgeContractSettlementPayoutAmounts(
                    hedgePayoutInSatoshis: 4_255_319,
                    longPayoutInSatoshis: 1_394_398
                )
        )
        #expect(request.hedgePayoutInSatoshis == 4_255_319)
        #expect(request.longPayoutInSatoshis == 1_394_398)
        #expect(request.minerFeeInSatoshis == 1_332)
        #expect(request.reviewSummary.settlementKind == .maturation)
        #expect(request.reviewSummary.fundingSatoshis == fundingRecord.funding.fundingSatoshis)
    }

    @Test("Creates AnyHedge liquidation settlement request")
    func createAnyHedgeLiquidationSettlementRequest() throws {
        let request = try makeFundingRecord().createSettlementRequest(
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof(
                    messageTimestamp: 615_644,
                    priceValue: 17_500
                )
        )

        #expect(request.settlementCondition == .liquidation)
        #expect(request.settlementKind == .liquidation)
        #expect(request.settlementPrice == 17_500)
        #expect(
            request.settlementPayoutAmounts == OpalHedge.BitcoinCash
                .AnyHedgeContractSettlementPayoutAmounts(
                    hedgePayoutInSatoshis: 5_649_717,
                    longPayoutInSatoshis: 1_332
                )
        )
        #expect(request.hedgePayoutInSatoshis == 5_649_717)
        #expect(request.longPayoutInSatoshis == 1_332)
        #expect(request.minerFeeInSatoshis == 0)
    }

    @Test("Rejects AnyHedge in-range settlement request before maturity")
    func rejectAnyHedgeInRangeSettlementRequestBeforeMaturity() throws {
        let error = try #require(captureSettlementConditionError {
            _ = try makeFundingRecord().createSettlementRequest(
                previousOracleProof: OpalHedgeContractFixtureBuilder
                    .makeStartingSettlementOracleProof(),
                settlementOracleProof: OpalHedgeContractFixtureBuilder
                    .makeSettlementOracleProof(
                        messageTimestamp: 615_644,
                        priceValue: 23_500
                    )
            )
        })

        #expect(error == .priceInRangeBeforeMaturity(settlementPrice: 23_500))
    }

    @Test("Settlement review summary excludes raw hashes, oracle messages, and signatures")
    func settlementReviewSummaryExcludesRawHashesOracleMessagesAndSignatures() throws {
        let summary = try makeFundingRecord().createSettlementRequest(
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof()
        ).reviewSummary
        let labels = Set(Mirror(reflecting: summary).children.compactMap(\.label))

        #expect(labels.contains("settlementPrice"))
        #expect(labels.contains("rawFundingTransactionHash") == false)
        #expect(labels.contains("rawSettlementTransactionHash") == false)
        #expect(labels.contains("rawPreviousOracleMessageHex") == false)
        #expect(labels.contains("rawPreviousOracleSignatureHex") == false)
        #expect(labels.contains("rawSettlementOracleMessageHex") == false)
        #expect(labels.contains("rawSettlementOracleSignatureHex") == false)
    }

    private func makeFundingRecord() throws -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord {
        let bundle = try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )

        return try bundle.createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
    }

    private func captureSettlementConditionError(
        _ operation: () throws -> Void
    ) -> OpalHedge.Core.SettlementConditionError? {
        do {
            try operation()
        } catch let error as OpalHedge.Core.SettlementConditionError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }
}
