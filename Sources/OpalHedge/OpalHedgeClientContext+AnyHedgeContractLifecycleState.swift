// OpalHedgeClientContext+AnyHedgeContractLifecycleState.swift

import OpalHedgeBitcoinCash
import OpalHedgeClient
import OpalHedgeCore

extension OpalHedgeClientContext {
    public func createAnyHedgeContractLifecycleState(
        from creationContext: OpalHedgeCoreContractCreationContext,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractLifecycleState {
        let plan = try OpalHedgeCoreContractPlan(from: creationContext)

        return try createAnyHedgeContractLifecycleState(
            from: plan,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        )
    }

    public func createAnyHedgeContractLifecycleState(
        from plan: OpalHedgeCoreContractPlan,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractLifecycleState {
        let bundle = try createAnyHedgeContractBundle(
            from: plan,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        )

        return try createAnyHedgeContractLifecycleState(
            from: bundle.dataDocument,
            network: network,
            scriptBytecode: scriptBytecode
        )
    }

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
