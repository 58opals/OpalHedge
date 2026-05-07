// OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmountsValidator.swift

import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmountsValidator {
    @Test("Creates AnyHedge contract settlement payout amounts")
    func createAnyHedgeContractSettlementPayoutAmounts() {
        let amounts = OpalHedge.BitcoinCash.AnyHedgeContractSettlementPayoutAmounts(
            hedgePayoutInSatoshis: 4_255_319,
            longPayoutInSatoshis: 1_394_398
        )

        #expect(amounts.hedgePayoutInSatoshis == 4_255_319)
        #expect(amounts.longPayoutInSatoshis == 1_394_398)
        #expect(amounts.totalPayoutInSatoshis == 5_649_717)
    }

    @Test("Creates AnyHedge contract settlement payout amounts from settlement outcome")
    func createAnyHedgeContractSettlementPayoutAmountsFromSettlementOutcome() throws {
        let outcome = try OpalHedge.Core.SettlementCalculator.calculateOutcome(
            parameters: OpalHedgeFixtureData.contractParameters,
            fundingSatoshis: 5_651_049,
            redeemPrice: 23_500
        )
        let amounts = OpalHedge.BitcoinCash.AnyHedgeContractSettlementPayoutAmounts(
            settlementOutcome: outcome
        )

        #expect(
            amounts == OpalHedge.BitcoinCash.AnyHedgeContractSettlementPayoutAmounts(
                hedgePayoutInSatoshis: 4_255_319,
                longPayoutInSatoshis: 1_394_398
            )
        )
    }
}
