// OpalHedgeCoreSettlementConditionError.swift

public enum OpalHedgeCoreSettlementConditionError: Error, Sendable, Equatable {
    case metadataSequence(Int64)
    case sequenceGap(previous: Int64, settlement: Int64)
    case previousMessageNotBeforeMaturity(previousTimestamp: Int64, maturityTimestamp: Int64)
    case settlementMessageBeforeStart(settlementTimestamp: Int64, startTimestamp: Int64)
    case settlementMessageBeforePrevious(
        previousTimestamp: Int64,
        settlementTimestamp: Int64
    )
    case invalidSettlementPrice(Int64)
    case priceInRangeBeforeMaturity(settlementPrice: Int64)
}
