// OpalHedgeCoreContractSettlement.swift

public struct OpalHedgeCoreContractSettlement: Sendable, Equatable {
    public let kind: OpalHedgeCoreSettlementKind
    public let settlementTransactionHash: String
    public let shortPayoutInSatoshis: Int64
    public let longPayoutInSatoshis: Int64
    public let settlementMessageHex: String?
    public let settlementSignatureHex: String?
    public let previousMessageHex: String?
    public let previousSignatureHex: String?
    public let settlementPrice: Int64?

    public init(
        kind: OpalHedgeCoreSettlementKind,
        settlementTransactionHash: String,
        shortPayoutInSatoshis: Int64,
        longPayoutInSatoshis: Int64,
        settlementMessageHex: String? = nil,
        settlementSignatureHex: String? = nil,
        previousMessageHex: String? = nil,
        previousSignatureHex: String? = nil,
        settlementPrice: Int64? = nil
    ) {
        self.kind = kind
        self.settlementTransactionHash = settlementTransactionHash
        self.shortPayoutInSatoshis = shortPayoutInSatoshis
        self.longPayoutInSatoshis = longPayoutInSatoshis
        self.settlementMessageHex = settlementMessageHex
        self.settlementSignatureHex = settlementSignatureHex
        self.previousMessageHex = previousMessageHex
        self.previousSignatureHex = previousSignatureHex
        self.settlementPrice = settlementPrice
    }
}
