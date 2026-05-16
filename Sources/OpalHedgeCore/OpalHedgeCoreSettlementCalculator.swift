// OpalHedgeCoreSettlementCalculator.swift

public enum OpalHedgeCoreSettlementCalculator {
    public static func calculateOutcome(
        parameters: OpalHedgeCoreContractParameters,
        fundingSatoshis: Int64,
        redeemPrice: Int64
    ) throws -> OpalHedgeCoreSettlementOutcome {
        do {
            let outcome = try performCalculateOutcome(
                parameters: parameters,
                fundingSatoshis: fundingSatoshis,
                redeemPrice: redeemPrice
            )
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.settlementPayoutCalculated,
                category: OpalHedgeCoreDiagnostics.Category.settlement,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("calculate_settlement_payout"),
                    OpalHedgeCoreDiagnostics.moduleField("core"),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.settlementPrice,
                        redeemPrice
                    ),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.satoshiCount,
                        outcome.totalPayoutSatsSafe
                    )
                ]
            )
            return outcome
        } catch {
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.settlementPayoutCalculationFailed,
                category: OpalHedgeCoreDiagnostics.Category.settlement,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("calculate_settlement_payout"),
                    OpalHedgeCoreDiagnostics.moduleField("core"),
                    OpalHedgeCoreDiagnostics.publicField(
                        OpalHedgeCoreDiagnostics.Field.settlementPrice,
                        redeemPrice
                    )
                ] + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func performCalculateOutcome(
        parameters: OpalHedgeCoreContractParameters,
        fundingSatoshis: Int64,
        redeemPrice: Int64
    ) throws -> OpalHedgeCoreSettlementOutcome {
        guard redeemPrice > 0 else {
            throw OpalHedgeCoreSettlementCalculationError.invalidRedeemPrice(redeemPrice)
        }
        guard parameters.lowLiquidationPrice > 0,
              parameters.highLiquidationPrice > parameters.lowLiquidationPrice else {
            throw OpalHedgeCoreSettlementCalculationError.invalidLiquidationRange(
                low: parameters.lowLiquidationPrice,
                high: parameters.highLiquidationPrice
            )
        }

        let clampedPrice = max(
            min(redeemPrice, parameters.highLiquidationPrice),
            parameters.lowLiquidationPrice
        )
        let satsForNominalUnits = parameters.nominalUnitsXSatsPerBch / clampedPrice
        let shortPayoutSatsUnsafe = try subtractingSatoshis(
            satsForNominalUnits,
            parameters.satsForNominalUnitsAtHighLiquidation
        )
        let shortPayoutSatsSafe = max(
            OpalHedgeCoreContractConstraintPolicy.dustLimitSatoshis,
            shortPayoutSatsUnsafe
        )
        let longPayoutSatsUnsafe = try subtractingSatoshis(
            parameters.payoutSats,
            shortPayoutSatsSafe
        )
        let longPayoutSatsSafe = max(
            OpalHedgeCoreContractConstraintPolicy.dustLimitSatoshis,
            longPayoutSatsUnsafe
        )
        let totalPayoutSatsSafe = try addingSatoshis(
            shortPayoutSatsSafe,
            longPayoutSatsSafe
        )
        guard fundingSatoshis >= totalPayoutSatsSafe else {
            throw OpalHedgeCoreSettlementCalculationError.insufficientFundingSatoshis(
                fundingSatoshis: fundingSatoshis,
                requiredSatoshis: totalPayoutSatsSafe
            )
        }

        let minerFeeSats = fundingSatoshis - totalPayoutSatsSafe

        return OpalHedgeCoreSettlementOutcome(
            clampedPrice: clampedPrice,
            shortPayoutSatsSafe: shortPayoutSatsSafe,
            longPayoutSatsSafe: longPayoutSatsSafe,
            totalPayoutSatsSafe: totalPayoutSatsSafe,
            satsForNominalUnits: satsForNominalUnits,
            minerFeeSats: minerFeeSats
        )
    }

    private static func subtractingSatoshis(
        _ lhs: Int64,
        _ rhs: Int64
    ) throws -> Int64 {
        let result = lhs.subtractingReportingOverflow(rhs)
        guard !result.overflow else {
            throw OpalHedgeCoreSettlementCalculationError.payoutSatoshisOverflow
        }
        return result.partialValue
    }

    private static func addingSatoshis(
        _ lhs: Int64,
        _ rhs: Int64
    ) throws -> Int64 {
        let result = lhs.addingReportingOverflow(rhs)
        guard !result.overflow else {
            throw OpalHedgeCoreSettlementCalculationError.payoutSatoshisOverflow
        }
        return result.partialValue
    }
}
