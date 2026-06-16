// OpalHedgeBitcoinCashAnyHedgeContractFundingRecord.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractFundingRecord: Sendable, Equatable {
    public let fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput
    public let contractScriptArtifact: OpalHedgeBitcoinCashContractScriptArtifact
    public let fundingIndex: Int
    public let funding: OpalHedgeCoreContractFunding
    public let draftData: OpalHedgeCoreContractDraftData
    public let dataDocument: OpalHedgeCoreContractDataDocument

    public var fundingRequestReviewSummary: OpalHedgeBitcoinCashAnyHedgeContractFundingReviewSummary {
        OpalHedgeBitcoinCashAnyHedgeContractFundingReviewSummary(
            contractAddressDisplayValue: fundingOutput.contractAddress.rawValue,
            network: fundingOutput.contractAddress.network,
            fundingSatoshis: fundingOutput.satoshis,
            payoutSatoshis: fundingOutput.payoutSatoshis,
            dustReserveSatoshis: fundingOutput.dustReserveSatoshis,
            contractScriptArtifact: contractScriptArtifact,
            domainDataDocumentByteCount: dataDocument.utf8Data.count
        )
    }

    public var fundingState: OpalHedgeBitcoinCashAnyHedgeContractFundingState {
        OpalHedgeBitcoinCashAnyHedgeContractFundingState(fundingRecord: self)
    }

    public var lifecycleState: OpalHedgeBitcoinCashAnyHedgeContractLifecycleState {
        OpalHedgeBitcoinCashAnyHedgeContractLifecycleState(fundingRecord: self)
    }

    public func createSettlementRequest(
        previousOracleProof: OpalHedgeCoreContractSettlementOracleProof,
        settlementOracleProof: OpalHedgeCoreContractSettlementOracleProof
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest {
        try OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest(
            domainFundingRecord: self,
            previousOracleDomainProof: previousOracleProof,
            settlementOracleDomainProof: settlementOracleProof
        )
    }
}
