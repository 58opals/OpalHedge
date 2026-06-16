// OpalHedgeBitcoinCashAnyHedgeContractFundingRequest.swift

import Foundation
import OpalHedgeBitcoinCash
import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractFundingRequest: Sendable, Equatable {
    public let fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput
    public let domainDataDocument: OpalHedgeCoreContractDataDocument
    public let rawRedeemScriptBytecode: Data
    public let contractScriptArtifact: OpalHedgeBitcoinCashContractScriptArtifact

    public var reviewSummary: OpalHedgeBitcoinCashAnyHedgeContractFundingReviewSummary {
        OpalHedgeBitcoinCashAnyHedgeContractFundingReviewSummary(fundingRequest: self)
    }

    @available(*, deprecated, renamed: "domainDataDocument")
    public var contractDataDocument: OpalHedgeCoreContractDataDocument {
        domainDataDocument
    }

    @available(*, deprecated, renamed: "rawRedeemScriptBytecode")
    public var redeemScriptBytecode: Data {
        rawRedeemScriptBytecode
    }

    public init(
        fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput,
        domainDataDocument: OpalHedgeCoreContractDataDocument,
        rawRedeemScriptBytecode: Data,
        contractScriptArtifact: OpalHedgeBitcoinCashContractScriptArtifact
    ) {
        self.fundingOutput = fundingOutput
        self.domainDataDocument = domainDataDocument
        self.rawRedeemScriptBytecode = rawRedeemScriptBytecode
        self.contractScriptArtifact = contractScriptArtifact
    }

    @available(*, deprecated, message: "Use init(fundingOutput:domainDataDocument:rawRedeemScriptBytecode:contractScriptArtifact:) so domain and raw script material are explicit.")
    public init(
        fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput,
        contractDataDocument: OpalHedgeCoreContractDataDocument,
        redeemScriptBytecode: Data,
        contractScriptArtifact: OpalHedgeBitcoinCashContractScriptArtifact
    ) {
        self.init(
            fundingOutput: fundingOutput,
            domainDataDocument: contractDataDocument,
            rawRedeemScriptBytecode: redeemScriptBytecode,
            contractScriptArtifact: contractScriptArtifact
        )
    }
}
