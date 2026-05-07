// OpalHedgeClientContext+AnyHedgeContractLifecycleState.swift

import OpalHedgeBitcoinCash
import OpalHedgeClient
import OpalHedgeCore

extension OpalHedgeClientContext {
    public func createAnyHedgeContractLifecycleState(
        from dataDocument: OpalHedgeCoreContractDataDocument,
        fundingIndex: Int = 0,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractLifecycleState {
        try OpalHedgeBitcoinCashAnyHedgeContractLifecycleState(
            dataDocument: dataDocument,
            fundingIndex: fundingIndex,
            network: network,
            scriptBytecode: scriptBytecode
        )
    }
}
