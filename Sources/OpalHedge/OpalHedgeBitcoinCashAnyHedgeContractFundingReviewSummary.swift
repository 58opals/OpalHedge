// OpalHedgeBitcoinCashAnyHedgeContractFundingReviewSummary.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractFundingReviewSummary: Sendable, Equatable {
    public let contractAddressDisplayValue: String
    public let network: OpalHedgeBitcoinCashNetwork
    public let fundingSatoshis: Int64
    public let payoutSatoshis: Int64
    public let dustReserveSatoshis: Int64
    public let contractScriptArtifact: OpalHedgeBitcoinCashContractScriptArtifact
    public let domainDataDocumentByteCount: Int

    public init(
        contractAddressDisplayValue: String,
        network: OpalHedgeBitcoinCashNetwork,
        fundingSatoshis: Int64,
        payoutSatoshis: Int64,
        dustReserveSatoshis: Int64,
        contractScriptArtifact: OpalHedgeBitcoinCashContractScriptArtifact,
        domainDataDocumentByteCount: Int
    ) {
        self.contractAddressDisplayValue = contractAddressDisplayValue
        self.network = network
        self.fundingSatoshis = fundingSatoshis
        self.payoutSatoshis = payoutSatoshis
        self.dustReserveSatoshis = dustReserveSatoshis
        self.contractScriptArtifact = contractScriptArtifact
        self.domainDataDocumentByteCount = domainDataDocumentByteCount
    }

    public init(fundingRequest: OpalHedgeBitcoinCashAnyHedgeContractFundingRequest) {
        self.init(
            contractAddressDisplayValue: fundingRequest.fundingOutput.contractAddress.rawValue,
            network: fundingRequest.fundingOutput.contractAddress.network,
            fundingSatoshis: fundingRequest.fundingOutput.satoshis,
            payoutSatoshis: fundingRequest.fundingOutput.payoutSatoshis,
            dustReserveSatoshis: fundingRequest.fundingOutput.dustReserveSatoshis,
            contractScriptArtifact: fundingRequest.contractScriptArtifact,
            domainDataDocumentByteCount: fundingRequest.domainDataDocument.utf8Data.count
        )
    }
}
