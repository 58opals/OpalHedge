// OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError.swift

public enum OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError: Error, Sendable, Equatable {
    case invalidSettlementTransactionHash(String)
    case missingFundingRecord
}
