// OpalHedgeBitcoinCashAnyHedgeContractFundingRequest.swift

import Foundation
import OpalHedgeBitcoinCash
import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractFundingRequest: Sendable, Equatable {
    public let fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput
    public let contractDataDocument: OpalHedgeCoreContractDataDocument
    public let redeemScriptBytecode: Data
    public let contractScriptArtifact: OpalHedgeBitcoinCashContractScriptArtifact

    public init(
        fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput,
        contractDataDocument: OpalHedgeCoreContractDataDocument,
        redeemScriptBytecode: Data,
        contractScriptArtifact: OpalHedgeBitcoinCashContractScriptArtifact
    ) {
        self.fundingOutput = fundingOutput
        self.contractDataDocument = contractDataDocument
        self.redeemScriptBytecode = redeemScriptBytecode
        self.contractScriptArtifact = contractScriptArtifact
    }
}
