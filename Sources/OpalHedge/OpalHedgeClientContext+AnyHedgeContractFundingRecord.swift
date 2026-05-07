// OpalHedgeClientContext+AnyHedgeContractFundingRecord.swift

import OpalHedgeBitcoinCash
import OpalHedgeClient
import OpalHedgeCore

extension OpalHedgeClientContext {
    public func createAnyHedgeContractFundingRecord(
        from creationContext: OpalHedgeCoreContractCreationContext,
        fundingTransactionHash: String,
        fundingOutputIndex: Int64,
        fundingSatoshis: Int64? = nil,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractFundingRecord {
        let bundle = try createAnyHedgeContractBundle(
            from: creationContext,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        )

        return try bundle.createFundingRecord(
            fundingTransactionHash: fundingTransactionHash,
            fundingOutputIndex: fundingOutputIndex,
            fundingSatoshis: fundingSatoshis
        )
    }
}
