// OpalHedgeBitcoinCashAnyHedgeContractLifecycleState.swift

import OpalHedgeCore

public enum OpalHedgeBitcoinCashAnyHedgeContractLifecycleState: Sendable, Equatable {
    case unfunded(OpalHedgeBitcoinCashAnyHedgeContractFundingRequest)
    case funded(OpalHedgeBitcoinCashAnyHedgeContractFundingRecord)
    case settled(OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord)

    public var isFunded: Bool {
        switch self {
        case .unfunded:
            false
        case .funded,
             .settled:
            true
        }
    }

    public var isSettled: Bool {
        switch self {
        case .unfunded,
             .funded:
            false
        case .settled:
            true
        }
    }

    public var fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput {
        switch self {
        case .unfunded(let fundingRequest):
            fundingRequest.fundingOutput
        case .funded(let fundingRecord):
            fundingRecord.fundingOutput
        case .settled(let settlementRecord):
            settlementRecord.fundingRecord.fundingOutput
        }
    }

    public var dataDocument: OpalHedgeCoreContractDataDocument {
        switch self {
        case .unfunded(let fundingRequest):
            fundingRequest.contractDataDocument
        case .funded(let fundingRecord):
            fundingRecord.dataDocument
        case .settled(let settlementRecord):
            settlementRecord.dataDocument
        }
    }

    public var fundingRequest: OpalHedgeBitcoinCashAnyHedgeContractFundingRequest? {
        switch self {
        case .unfunded(let fundingRequest):
            fundingRequest
        case .funded,
             .settled:
            nil
        }
    }

    public var fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord? {
        switch self {
        case .unfunded:
            nil
        case .funded(let fundingRecord):
            fundingRecord
        case .settled(let settlementRecord):
            settlementRecord.fundingRecord
        }
    }

    public var settlementRecord: OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord? {
        switch self {
        case .unfunded,
             .funded:
            nil
        case .settled(let settlementRecord):
            settlementRecord
        }
    }

    public var settlementRequest: OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest? {
        settlementRecord?.settlementRequest
    }

    public var funding: OpalHedgeCoreContractFunding? {
        switch self {
        case .unfunded:
            nil
        case .funded(let fundingRecord):
            fundingRecord.funding
        case .settled(let settlementRecord):
            settlementRecord.funding
        }
    }

    public var settlement: OpalHedgeCoreContractSettlement? {
        settlementRecord?.settlement
    }

    public var settlementDataDocument: OpalHedgeCoreContractDataDocument? {
        settlementRecord?.dataDocument
    }

    public var settlementSummary: OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary? {
        settlementRecord?.settlementSummary
    }

    public init(bundle: OpalHedgeBitcoinCashAnyHedgeContractBundle) {
        self = .unfunded(bundle.fundingRequest)
    }

    public init(fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord) {
        self = .funded(fundingRecord)
    }

    public init(settlementRecord: OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord) {
        self = .settled(settlementRecord)
    }
}
