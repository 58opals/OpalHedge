// OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError.swift

public enum OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError: Error, Sendable, Equatable {
    case invalidPayoutSatoshis(Int64)
    case invalidDustReserveSatoshis(Int64)
    case fundingSatoshisOverflow(
        payoutSatoshis: Int64,
        dustReserveSatoshis: Int64
    )
}
