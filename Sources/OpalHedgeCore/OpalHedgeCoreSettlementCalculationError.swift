// OpalHedgeCoreSettlementCalculationError.swift

public enum OpalHedgeCoreSettlementCalculationError: Error, Sendable, Equatable {
    case invalidRedeemPrice(Int64)
    case invalidLiquidationRange(low: Int64, high: Int64)
    case insufficientFundingSatoshis(fundingSatoshis: Int64, requiredSatoshis: Int64)
}
