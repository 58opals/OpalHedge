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

    @Test("Rejects underfunded settlement outcome")
    func rejectUnderfundedSettlementOutcome() {
        let error = OpalHedgeTypedErrorCaptureTool.captureSettlementCalculationError {
            _ = try OpalHedge.Core.SettlementCalculator.calculateOutcome(
                parameters: OpalHedgeFixtureData.contractParameters,
                fundingSatoshis: 5_649_716,
                redeemPrice: 23_500
            )
        }

        #expect(
            error == .insufficientFundingSatoshis(
                fundingSatoshis: 5_649_716,
                requiredSatoshis: 5_649_717
            )
        )
    }

    @Test("Rejects settlement payout overflow without trapping")
    func rejectSettlementPayoutOverflowWithoutTrapping() {
        let parameters = OpalHedge.Core.ContractParameters(
            oraclePublicKey: OpalHedgeFixtureData.contractParameters.oraclePublicKey,
            lowLiquidationPrice: 1,
            highLiquidationPrice: 2,
            startTimestamp: OpalHedgeFixtureData.contractParameters.startTimestamp,
            maturityTimestamp: OpalHedgeFixtureData.contractParameters.maturityTimestamp,
            nominalUnitsXSatsPerBch: Int64.max,
            satsForNominalUnitsAtHighLiquidation: 0,
            payoutSats: 0,
            shortLockScript: OpalHedgeFixtureData.contractParameters.shortLockScript,
            longLockScript: OpalHedgeFixtureData.contractParameters.longLockScript,
            enableMutualRedemption: OpalHedgeFixtureData.contractParameters
                .enableMutualRedemption,
            shortMutualRedeemPublicKey: OpalHedgeFixtureData.contractParameters
                .shortMutualRedeemPublicKey,
            longMutualRedeemPublicKey: OpalHedgeFixtureData.contractParameters
                .longMutualRedeemPublicKey
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureSettlementCalculationError {
            _ = try OpalHedge.Core.SettlementCalculator.calculateOutcome(
                parameters: parameters,
                fundingSatoshis: Int64.max,
                redeemPrice: 1
            )
        }

        #expect(error == .payoutSatoshisOverflow)
    }

    @Test("Rejects empty liquidation range")
    func rejectEmptyLiquidationRange() {
        let parameters = OpalHedge.Core.ContractParameters(
            oraclePublicKey: OpalHedgeFixtureData.contractParameters.oraclePublicKey,
            lowLiquidationPrice: OpalHedgeFixtureData.contractParameters.lowLiquidationPrice,
            highLiquidationPrice: OpalHedgeFixtureData.contractParameters.lowLiquidationPrice,
            startTimestamp: OpalHedgeFixtureData.contractParameters.startTimestamp,
            maturityTimestamp: OpalHedgeFixtureData.contractParameters.maturityTimestamp,
            nominalUnitsXSatsPerBch: OpalHedgeFixtureData.contractParameters
                .nominalUnitsXSatsPerBch,
            satsForNominalUnitsAtHighLiquidation: OpalHedgeFixtureData.contractParameters
                .satsForNominalUnitsAtHighLiquidation,
            payoutSats: OpalHedgeFixtureData.contractParameters.payoutSats,
            shortLockScript: OpalHedgeFixtureData.contractParameters.shortLockScript,
            longLockScript: OpalHedgeFixtureData.contractParameters.longLockScript,
            enableMutualRedemption: OpalHedgeFixtureData.contractParameters
                .enableMutualRedemption,
            shortMutualRedeemPublicKey: OpalHedgeFixtureData.contractParameters
                .shortMutualRedeemPublicKey,
            longMutualRedeemPublicKey: OpalHedgeFixtureData.contractParameters
                .longMutualRedeemPublicKey
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureSettlementCalculationError {
            _ = try OpalHedge.Core.SettlementCalculator.calculateOutcome(
                parameters: parameters,
                fundingSatoshis: 5_651_049,
                redeemPrice: 17_700
            )
        }

        #expect(
            error == .invalidLiquidationRange(
                low: 17_700,
                high: 17_700
            )
        )
    }
}
