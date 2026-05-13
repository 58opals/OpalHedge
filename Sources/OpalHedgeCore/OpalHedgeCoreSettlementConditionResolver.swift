// OpalHedgeCoreSettlementConditionResolver.swift

public enum OpalHedgeCoreSettlementConditionResolver {
    public static func resolve(
        parameters: OpalHedgeCoreContractParameters,
        previousTimestamp: Int64,
        previousSequence: Int64,
        settlementTimestamp: Int64,
        settlementSequence: Int64,
        settlementPrice: Int64
    ) throws -> OpalHedgeCoreSettlementCondition {
        guard previousSequence > 0 else {
            throw OpalHedgeCoreSettlementConditionError.metadataSequence(previousSequence)
        }
        guard previousSequence < Int64.max,
              settlementSequence == previousSequence + 1 else {
            throw OpalHedgeCoreSettlementConditionError.sequenceGap(
                previous: previousSequence,
                settlement: settlementSequence
            )
        }
        guard previousTimestamp < parameters.maturityTimestamp else {
            throw OpalHedgeCoreSettlementConditionError.previousMessageNotBeforeMaturity(
                previousTimestamp: previousTimestamp,
                maturityTimestamp: parameters.maturityTimestamp
            )
        }
        guard settlementTimestamp >= parameters.startTimestamp else {
            throw OpalHedgeCoreSettlementConditionError.settlementMessageBeforeStart(
                settlementTimestamp: settlementTimestamp,
                startTimestamp: parameters.startTimestamp
            )
        }
        guard settlementTimestamp >= previousTimestamp else {
            throw OpalHedgeCoreSettlementConditionError.settlementMessageBeforePrevious(
                previousTimestamp: previousTimestamp,
                settlementTimestamp: settlementTimestamp
            )
        }
        guard settlementPrice > 0 else {
            throw OpalHedgeCoreSettlementConditionError.invalidSettlementPrice(settlementPrice)
        }

        let clampedPrice = max(
            min(settlementPrice, parameters.highLiquidationPrice),
            parameters.lowLiquidationPrice
        )
        let onOrAfterMaturity = settlementTimestamp >= parameters.maturityTimestamp
        let priceOutOfBounds = clampedPrice == parameters.lowLiquidationPrice
            || clampedPrice >= parameters.highLiquidationPrice

        if onOrAfterMaturity {
            return .maturation
        }
        if priceOutOfBounds {
            return .liquidation
        }

        throw OpalHedgeCoreSettlementConditionError.priceInRangeBeforeMaturity(
            settlementPrice: settlementPrice
        )
    }
}
