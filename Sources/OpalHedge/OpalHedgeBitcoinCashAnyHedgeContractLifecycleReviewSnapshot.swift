// OpalHedgeBitcoinCashAnyHedgeContractLifecycleReviewSnapshot.swift

public struct OpalHedgeBitcoinCashAnyHedgeContractLifecycleReviewSnapshot: Sendable, Equatable {
    public let phase: OpalHedgeBitcoinCashAnyHedgeContractLifecyclePhase
    public let fundingReviewSummary: OpalHedgeBitcoinCashAnyHedgeContractFundingReviewSummary
    public let settlementReviewSummary: OpalHedgeBitcoinCashAnyHedgeContractSettlementReviewSummary?

    public var isFunded: Bool {
        phase != .unfunded
    }

    public var isSettled: Bool {
        phase == .settled
    }

    public init(lifecycleState: OpalHedgeBitcoinCashAnyHedgeContractLifecycleState) {
        switch lifecycleState {
        case .unfunded(let fundingRequest):
            self.phase = .unfunded
            self.fundingReviewSummary = fundingRequest.reviewSummary
            self.settlementReviewSummary = nil
        case .funded(let fundingRecord):
            self.phase = .funded
            self.fundingReviewSummary = fundingRecord.fundingRequestReviewSummary
            self.settlementReviewSummary = nil
        case .settled(let settlementRecord):
            self.phase = .settled
            self.fundingReviewSummary = settlementRecord.fundingRecord
                .fundingRequestReviewSummary
            self.settlementReviewSummary = settlementRecord.settlementSummary.reviewSummary
        }
    }
}
