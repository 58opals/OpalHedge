// OpalHedgeCoreContractSettlementPayoutAmounts.swift

public struct OpalHedgeCoreContractSettlementPayoutAmounts: Sendable, Equatable {
    public let shortPayoutInSatoshis: Int64
    public let longPayoutInSatoshis: Int64

    public var totalPayoutInSatoshis: Int64 {
        shortPayoutInSatoshis + longPayoutInSatoshis
    }

    public init(
        shortPayoutInSatoshis: Int64,
        longPayoutInSatoshis: Int64
    ) {
        self.shortPayoutInSatoshis = shortPayoutInSatoshis
        self.longPayoutInSatoshis = longPayoutInSatoshis
    }
}
