// OpalHedgeCoreContractSettlement.swift

public struct OpalHedgeCoreContractSettlement: Sendable, Equatable {
    public let kind: OpalHedgeCoreSettlementKind
    public let settlementTransactionHash: String
    public let payoutAmounts: OpalHedgeCoreContractSettlementPayoutAmounts
    public let settlementMessageHex: String?
    public let settlementSignatureHex: String?
    public let previousMessageHex: String?
    public let previousSignatureHex: String?
    public let settlementPrice: Int64?

    public var shortPayoutInSatoshis: Int64 {
        payoutAmounts.shortPayoutInSatoshis
    }

    public var longPayoutInSatoshis: Int64 {
        payoutAmounts.longPayoutInSatoshis
    }

    public var totalPayoutInSatoshis: Int64 {
        payoutAmounts.totalPayoutInSatoshis
    }

    public init(
        kind: OpalHedgeCoreSettlementKind,
        settlementTransactionHash: String,
        payoutAmounts: OpalHedgeCoreContractSettlementPayoutAmounts,
        settlementMessageHex: String? = nil,
        settlementSignatureHex: String? = nil,
        previousMessageHex: String? = nil,
        previousSignatureHex: String? = nil,
        settlementPrice: Int64? = nil
    ) {
        self.kind = kind
        self.settlementTransactionHash = settlementTransactionHash
        self.payoutAmounts = payoutAmounts
        self.settlementMessageHex = settlementMessageHex
        self.settlementSignatureHex = settlementSignatureHex
        self.previousMessageHex = previousMessageHex
        self.previousSignatureHex = previousSignatureHex
        self.settlementPrice = settlementPrice
    }

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
        self.init(
            kind: kind,
            settlementTransactionHash: settlementTransactionHash,
            payoutAmounts: OpalHedgeCoreContractSettlementPayoutAmounts(
                shortPayoutInSatoshis: shortPayoutInSatoshis,
                longPayoutInSatoshis: longPayoutInSatoshis
            ),
            settlementMessageHex: settlementMessageHex,
            settlementSignatureHex: settlementSignatureHex,
            previousMessageHex: previousMessageHex,
            previousSignatureHex: previousSignatureHex,
            settlementPrice: settlementPrice
        )
    }
}
