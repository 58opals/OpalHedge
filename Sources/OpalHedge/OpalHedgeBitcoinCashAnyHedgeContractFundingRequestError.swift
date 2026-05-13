// OpalHedgeBitcoinCashAnyHedgeContractFundingRequestError.swift

public enum OpalHedgeBitcoinCashAnyHedgeContractFundingRequestError: Error, Sendable, Equatable {
    case contractAlreadyFunded(fundingCount: Int)
}
