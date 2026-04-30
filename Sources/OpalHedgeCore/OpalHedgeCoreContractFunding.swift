// OpalHedgeCoreContractFunding.swift

public struct OpalHedgeCoreContractFunding: Sendable, Equatable {
    public let fundingTransactionHash: String
    public let fundingOutputIndex: Int64
    public let fundingSatoshis: Int64
    public let settlement: OpalHedgeCoreContractSettlement?

    public init(
        fundingTransactionHash: String,
        fundingOutputIndex: Int64,
        fundingSatoshis: Int64,
        settlement: OpalHedgeCoreContractSettlement? = nil
    ) {
        self.fundingTransactionHash = fundingTransactionHash
        self.fundingOutputIndex = fundingOutputIndex
        self.fundingSatoshis = fundingSatoshis
        self.settlement = settlement
    }
}
