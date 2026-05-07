// OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmounts.swift

import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmounts: Sendable, Equatable {
    public let hedgePayoutInSatoshis: Int64
    public let longPayoutInSatoshis: Int64

    public var totalPayoutInSatoshis: Int64 {
        hedgePayoutInSatoshis + longPayoutInSatoshis
    }

    public init(
        hedgePayoutInSatoshis: Int64,
        longPayoutInSatoshis: Int64
    ) {
        self.hedgePayoutInSatoshis = hedgePayoutInSatoshis
        self.longPayoutInSatoshis = longPayoutInSatoshis
    }

    public init(settlementOutcome: OpalHedgeCoreSettlementOutcome) {
        self.init(
            hedgePayoutInSatoshis: settlementOutcome.shortPayoutSatsSafe,
            longPayoutInSatoshis: settlementOutcome.longPayoutSatsSafe
        )
    }

    var contractSettlementPayoutAmounts: OpalHedgeCoreContractSettlementPayoutAmounts {
        OpalHedgeCoreContractSettlementPayoutAmounts(
            shortPayoutInSatoshis: hedgePayoutInSatoshis,
            longPayoutInSatoshis: longPayoutInSatoshis
        )
    }
}
