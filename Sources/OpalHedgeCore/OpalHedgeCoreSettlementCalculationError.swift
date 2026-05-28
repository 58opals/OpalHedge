// OpalHedgeCoreSettlementCalculationError.swift

public enum OpalHedgeCoreSettlementCalculationError: Error, Sendable, Equatable {
    case invalidRedeemPrice(Int64)
    case invalidLiquidationRange(low: Int64, high: Int64)
    case invalidNominalUnitsXSatsPerBch(Int64)
    case invalidPayoutSatoshis(Int64)
    case payoutSatoshisOverflow
    case insufficientFundingSatoshis(fundingSatoshis: Int64, requiredSatoshis: Int64)
}
