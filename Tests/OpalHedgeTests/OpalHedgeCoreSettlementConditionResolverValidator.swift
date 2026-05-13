// OpalHedgeCoreSettlementConditionResolverValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreSettlementConditionResolverValidator {
    @Test("Resolves maturation at maturity timestamp")
    func resolveMaturationAtMaturityTimestamp() throws {
        let condition = try OpalHedge.Core.SettlementConditionResolver.resolve(
            parameters: OpalHedgeFixtureData.contractParameters,
            previousTimestamp: 6_663_642,
            previousSequence: 1,
            settlementTimestamp: 6_663_643,
            settlementSequence: 2,
            settlementPrice: 23_500
        )

        #expect(condition == .maturation)
    }

    @Test("Resolves liquidation before maturity when price is out of bounds")
    func resolveLiquidationBeforeMaturityWhenPriceIsOutOfBounds() throws {
        let condition = try OpalHedge.Core.SettlementConditionResolver.resolve(
            parameters: OpalHedgeFixtureData.contractParameters,
            previousTimestamp: 615_642,
            previousSequence: 1,
            settlementTimestamp: 615_643,
            settlementSequence: 2,
            settlementPrice: 17_500
        )

        #expect(condition == .liquidation)
    }

    @Test("Rejects in-range price before maturity")
    func rejectInRangePriceBeforeMaturity() {
        let error = OpalHedgeTypedErrorCaptureTool.captureSettlementConditionError {
            _ = try OpalHedge.Core.SettlementConditionResolver.resolve(
                parameters: OpalHedgeFixtureData.contractParameters,
                previousTimestamp: 615_642,
                previousSequence: 1,
                settlementTimestamp: 615_643,
                settlementSequence: 2,
                settlementPrice: 23_500
            )
        }

        #expect(error == .priceInRangeBeforeMaturity(settlementPrice: 23_500))
    }

    @Test("Rejects settlement timestamp before previous timestamp")
    func rejectSettlementTimestampBeforePreviousTimestamp() {
        let error = OpalHedgeTypedErrorCaptureTool.captureSettlementConditionError {
            _ = try OpalHedge.Core.SettlementConditionResolver.resolve(
                parameters: OpalHedgeFixtureData.contractParameters,
                previousTimestamp: 615_644,
                previousSequence: 1,
                settlementTimestamp: 615_643,
                settlementSequence: 2,
                settlementPrice: 17_500
            )
        }

        #expect(
            error == .settlementMessageBeforePrevious(
                previousTimestamp: 615_644,
                settlementTimestamp: 615_643
            )
        )
    }

    @Test("Rejects max previous sequence without overflowing")
    func rejectMaxPreviousSequenceWithoutOverflowing() {
        let error = OpalHedgeTypedErrorCaptureTool.captureSettlementConditionError {
            _ = try OpalHedge.Core.SettlementConditionResolver.resolve(
                parameters: OpalHedgeFixtureData.contractParameters,
                previousTimestamp: 615_642,
                previousSequence: Int64.max,
                settlementTimestamp: 615_643,
                settlementSequence: Int64.max,
                settlementPrice: 17_500
            )
        }

        #expect(
            error == .sequenceGap(
                previous: Int64.max,
                settlement: Int64.max
            )
        )
    }
}
