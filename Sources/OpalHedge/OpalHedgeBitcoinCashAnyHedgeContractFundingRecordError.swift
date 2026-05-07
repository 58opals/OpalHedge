// OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError.swift

public enum OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError: Error, Sendable, Equatable {
    case missingFundingRecord(index: Int)
    case invalidFundingTransactionHash(String)
    case invalidFundingOutputIndex(Int64)
    case inconsistentFundingSatoshis(expected: Int64, actual: Int64)
}
