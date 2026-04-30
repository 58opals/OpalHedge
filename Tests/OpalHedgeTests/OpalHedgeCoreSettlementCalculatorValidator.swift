// OpalHedgeCoreSettlementCalculatorValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreSettlementCalculatorValidator {
    @Test("Calculates simple hedge maturation outcome")
    func calculateSimpleHedgeMaturationOutcome() throws {
        let outcome = try OpalHedge.Core.SettlementCalculator.calculateOutcome(
            parameters: OpalHedgeFixtureData.contractParameters,
            fundingSatoshis: 5_651_049,
            redeemPrice: 23_500
        )

        #expect(outcome.clampedPrice == 23_500)
        #expect(outcome.shortPayoutSatsSafe == 4_255_319)
        #expect(outcome.longPayoutSatsSafe == 1_394_398)
        #expect(outcome.totalPayoutSatsSafe == 5_649_717)
        #expect(outcome.satsForNominalUnits == 4_255_319)
        #expect(outcome.minerFeeSats == 1_332)
    }

    @Test("Calculates simple hedge low liquidation outcome")
    func calculateSimpleHedgeLowLiquidationOutcome() throws {
        let outcome = try OpalHedge.Core.SettlementCalculator.calculateOutcome(
            parameters: OpalHedgeFixtureData.contractParameters,
            fundingSatoshis: 5_651_049,
            redeemPrice: 17_500
        )

        #expect(outcome.clampedPrice == 17_700)
        #expect(outcome.shortPayoutSatsSafe == 5_649_717)
        #expect(outcome.longPayoutSatsSafe == 1_332)
        #expect(outcome.totalPayoutSatsSafe == 5_651_049)
        #expect(outcome.satsForNominalUnits == 5_649_717)
        #expect(outcome.minerFeeSats == 0)
    }
}
