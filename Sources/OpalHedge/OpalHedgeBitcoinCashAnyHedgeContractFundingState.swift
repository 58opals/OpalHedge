// OpalHedgeBitcoinCashAnyHedgeContractFundingState.swift

import OpalHedgeCore

public enum OpalHedgeBitcoinCashAnyHedgeContractFundingState: Sendable, Equatable {
    case unfunded(OpalHedgeBitcoinCashAnyHedgeContractFundingRequest)
    case funded(OpalHedgeBitcoinCashAnyHedgeContractFundingRecord)

    public var isFunded: Bool {
        switch self {
        case .unfunded:
            false
        case .funded:
            true
        }
    }

    public var fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput {
        switch self {
        case .unfunded(let fundingRequest):
            fundingRequest.fundingOutput
        case .funded(let fundingRecord):
            fundingRecord.fundingOutput
        }
    }

    public var dataDocument: OpalHedgeCoreContractDataDocument {
        switch self {
        case .unfunded(let fundingRequest):
            fundingRequest.contractDataDocument
        case .funded(let fundingRecord):
            fundingRecord.dataDocument
        }
    }

    public var fundingRequest: OpalHedgeBitcoinCashAnyHedgeContractFundingRequest? {
        switch self {
        case .unfunded(let fundingRequest):
            fundingRequest
        case .funded:
            nil
        }
    }

    public var fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord? {
        switch self {
        case .unfunded:
            nil
        case .funded(let fundingRecord):
            fundingRecord
        }
    }

    public var funding: OpalHedgeCoreContractFunding? {
        fundingRecord?.funding
    }

    public init(bundle: OpalHedgeBitcoinCashAnyHedgeContractBundle) {
        self = .unfunded(bundle.fundingRequest)
    }

    public init(fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord) {
        self = .funded(fundingRecord)
    }
}
