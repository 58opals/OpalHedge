// OpalHedgeCoreSettlementCalculator.swift

import OpalDiagnostics

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
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.settlement).record(
                event: OpalDiagnostics.Event.settlementPayoutCalculated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("calculate_settlement_payout"),
                    OpalDiagnostics.Field.moduleField("core"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.settlementPrice,
                        redeemPrice
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.satoshiCount,
                        outcome.totalPayoutSatsSafe
                    )
                ]
            )
            return outcome
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.settlement).record(
                event: OpalDiagnostics.Event.settlementPayoutCalculationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("calculate_settlement_payout"),
                    OpalDiagnostics.Field.moduleField("core"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.settlementPrice,
                        redeemPrice
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
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
        try validateParameters(parameters)

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

    private static func validateParameters(
        _ parameters: OpalHedgeCoreContractParameters
    ) throws {
        guard parameters.lowLiquidationPrice > 0,
              parameters.highLiquidationPrice > parameters.lowLiquidationPrice else {
            throw OpalHedgeCoreSettlementCalculationError.invalidLiquidationRange(
                low: parameters.lowLiquidationPrice,
                high: parameters.highLiquidationPrice
            )
        }
        guard parameters.payoutSats >= OpalHedgeCoreContractConstraintPolicy.dustLimitSatoshis,
              parameters.payoutSats <= OpalHedgeCoreContractConstraintPolicy.maxContractSatoshis else {
            throw OpalHedgeCoreSettlementCalculationError.invalidPayoutSatoshis(
                parameters.payoutSats
            )
        }
        guard parameters.nominalUnitsXSatsPerBch > 0 else {
            throw OpalHedgeCoreSettlementCalculationError
                .invalidNominalUnitsXSatsPerBch(parameters.nominalUnitsXSatsPerBch)
        }
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
