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
        do {
            let condition = try performResolve(
                parameters: parameters,
                previousTimestamp: previousTimestamp,
                previousSequence: previousSequence,
                settlementTimestamp: settlementTimestamp,
                settlementSequence: settlementSequence,
                settlementPrice: settlementPrice
            )
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.settlementConditionResolved,
                category: OpalHedgeCoreDiagnostics.Category.settlement,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("resolve_settlement_condition"),
                    OpalHedgeCoreDiagnostics.moduleField("core"),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.settlementKind,
                        settlementKind(for: condition)
                    ),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.settlementPrice,
                        settlementPrice
                    )
                ]
            )
            return condition
        } catch {
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.settlementConditionResolutionFailed,
                category: OpalHedgeCoreDiagnostics.Category.settlement,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("resolve_settlement_condition"),
                    OpalHedgeCoreDiagnostics.moduleField("core"),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.settlementPrice,
                        settlementPrice
                    )
                ] + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func performResolve(
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

        let onOrAfterMaturity = settlementTimestamp >= parameters.maturityTimestamp
        let priceOutOfBounds = settlementPrice <= parameters.lowLiquidationPrice
            || settlementPrice >= parameters.highLiquidationPrice

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

    private static func settlementKind(
        for condition: OpalHedgeCoreSettlementCondition
    ) -> String {
        switch condition {
        case .maturation:
            "maturation"
        case .liquidation:
            "liquidation"
        }
    }
}
