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
        domainDataDocument
    }

    public var domainDataDocument: OpalHedgeCoreContractDataDocument {
        switch self {
        case .unfunded(let fundingRequest):
            fundingRequest.domainDataDocument
        case .funded(let fundingRecord):
            fundingRecord.dataDocument
        }
    }

    public var fundingRequest: OpalHedgeBitcoinCashAnyHedgeContractFundingRequest? {
        domainFundingRequest
    }

    public var domainFundingRequest: OpalHedgeBitcoinCashAnyHedgeContractFundingRequest? {
        switch self {
        case .unfunded(let fundingRequest):
            fundingRequest
        case .funded:
            nil
        }
    }

    public var fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord? {
        domainFundingRecord
    }

    public var domainFundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord? {
        switch self {
        case .unfunded:
            nil
        case .funded(let fundingRecord):
            fundingRecord
        }
    }

    public var funding: OpalHedgeCoreContractFunding? {
        domainFunding
    }

    public var domainFunding: OpalHedgeCoreContractFunding? {
        domainFundingRecord?.funding
    }

    package init(bundle: OpalHedgeBitcoinCashAnyHedgeContractBundle) {
        self = .unfunded(bundle.fundingRequest)
    }

    public init(fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord) {
        self = .funded(fundingRecord)
    }
}
