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

    public func createAnyHedgeContractFundingRecord(
        from dataDocument: OpalHedgeCoreContractDataDocument,
        fundingIndex: Int = 0,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractFundingRecord {
        try OpalHedgeBitcoinCashAnyHedgeContractFundingRecord(
            dataDocument: dataDocument,
            fundingIndex: fundingIndex,
            network: network,
            scriptBytecode: scriptBytecode
        )
    }
}
