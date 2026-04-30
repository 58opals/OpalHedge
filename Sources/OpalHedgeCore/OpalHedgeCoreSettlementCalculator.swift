// OpalHedgeCoreSettlementCalculator.swift

public enum OpalHedgeCoreSettlementCalculator {
    private static let dustLimit: Int64 = 1_332

    public static func calculateOutcome(
        parameters: OpalHedgeCoreContractParameters,
        fundingSatoshis: Int64,
        redeemPrice: Int64
    ) throws -> OpalHedgeCoreSettlementOutcome {
        guard redeemPrice > 0 else {
            throw OpalHedgeCoreSettlementCalculationError.invalidRedeemPrice(redeemPrice)
        }
        guard parameters.lowLiquidationPrice > 0,
              parameters.highLiquidationPrice >= parameters.lowLiquidationPrice else {
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
        let shortPayoutSatsUnsafe = satsForNominalUnits - parameters.satsForNominalUnitsAtHighLiquidation
        let shortPayoutSatsSafe = max(dustLimit, shortPayoutSatsUnsafe)
        let longPayoutSatsUnsafe = parameters.payoutSats - shortPayoutSatsSafe
        let longPayoutSatsSafe = max(dustLimit, longPayoutSatsUnsafe)
        let totalPayoutSatsSafe = shortPayoutSatsSafe + longPayoutSatsSafe
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
}
