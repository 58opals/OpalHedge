// OpalHedgeCoreSettlementConditionResolverValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreSettlementConditionResolverValidator {
    @Test("Resolves maturation at maturity timestamp")
    func resolveMaturationAtMaturityTimestamp() throws {
        let condition = try resolveCondition(
            previousTimestamp: 6_663_642,
            settlementTimestamp: 6_663_643,
            settlementPrice: 23_500
        )

        #expect(condition == .maturation)
    }

    @Test("Resolves liquidation before maturity when price is out of bounds")
    func resolveLiquidationBeforeMaturityWhenPriceIsOutOfBounds() throws {
        let condition = try resolveCondition(
            settlementPrice: 17_500
        )

        #expect(condition == .liquidation)
    }

    @Test("Rejects in-range price before maturity")
    func rejectInRangePriceBeforeMaturity() throws {
        let error = try #require(OpalHedgeTypedErrorCaptureTool.captureSettlementConditionError {
            _ = try resolveCondition(
                settlementPrice: 23_500
            )
        })

        #expect(error == .priceInRangeBeforeMaturity(settlementPrice: 23_500))
    }

    @Test("Rejects settlement timestamp before previous timestamp")
    func rejectSettlementTimestampBeforePreviousTimestamp() {
        let error = OpalHedgeTypedErrorCaptureTool.captureSettlementConditionError {
            _ = try resolveCondition(
                previousTimestamp: 615_644,
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

    @Test("Rejects nonpositive previous timestamp")
    func rejectNonpositivePreviousTimestamp() throws {
        let error = try #require(OpalHedgeTypedErrorCaptureTool.captureSettlementConditionError {
            _ = try resolveCondition(
                previousTimestamp: 0,
                settlementPrice: 17_500
            )
        })

        #expect(error == .invalidPreviousTimestamp(0))
    }

    @Test("Rejects max previous sequence without overflowing")
    func rejectMaxPreviousSequenceWithoutOverflowing() {
        let error = OpalHedgeTypedErrorCaptureTool.captureSettlementConditionError {
            _ = try resolveCondition(
                previousSequence: Int64.max,
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

    private func resolveCondition(
        previousTimestamp: Int64 = 615_642,
        previousSequence: Int64 = 1,
        settlementTimestamp: Int64 = 615_643,
        settlementSequence: Int64 = 2,
        settlementPrice: Int64
    ) throws -> OpalHedge.Core.SettlementCondition {
        try OpalHedge.Core.SettlementConditionResolver.resolve(
            parameters: OpalHedgeFixtureData.contractParameters,
            previousTimestamp: previousTimestamp,
            previousSequence: previousSequence,
            settlementTimestamp: settlementTimestamp,
            settlementSequence: settlementSequence,
            settlementPrice: settlementPrice
        )
    }
}
