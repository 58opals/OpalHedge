// OpalHedgeBitcoinCashAnyHedgeContractSettlementReviewSummary.swift

import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractSettlementReviewSummary: Sendable, Equatable {
    public let settlementKind: OpalHedgeCoreSettlementKind
    public let fundingOutputIndex: Int64
    public let fundingSatoshis: Int64
    public let settlementPrice: Int64
    public let settlementPayoutAmounts: OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmounts
    public let minerFeeInSatoshis: Int64
    public let previousOracleMessageTimestamp: Int64
    public let previousOracleMessageSequence: Int64
    public let settlementOracleMessageTimestamp: Int64
    public let settlementOracleMessageSequence: Int64

    public var hedgePayoutInSatoshis: Int64 {
        settlementPayoutAmounts.hedgePayoutInSatoshis
    }

    public var longPayoutInSatoshis: Int64 {
        settlementPayoutAmounts.longPayoutInSatoshis
    }

    public var totalPayoutInSatoshis: Int64 {
        settlementPayoutAmounts.totalPayoutInSatoshis
    }

    public init(settlementRequest: OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest) {
        self.settlementKind = settlementRequest.settlementKind
        self.fundingOutputIndex = settlementRequest.domainFunding.fundingOutputIndex
        self.fundingSatoshis = settlementRequest.domainFunding.fundingSatoshis
        self.settlementPrice = settlementRequest.settlementPrice
        self.settlementPayoutAmounts = settlementRequest.settlementPayoutAmounts
        self.minerFeeInSatoshis = settlementRequest.minerFeeInSatoshis
        self.previousOracleMessageTimestamp = settlementRequest.previousOracleDomainProof
            .messageTimestamp
        self.previousOracleMessageSequence = settlementRequest.previousOracleDomainProof
            .messageSequence
        self.settlementOracleMessageTimestamp = settlementRequest.settlementOracleDomainProof
            .messageTimestamp
        self.settlementOracleMessageSequence = settlementRequest.settlementOracleDomainProof
            .messageSequence
    }
}
