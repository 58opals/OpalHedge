// OpalHedgeClientContext+AnyHedgeContractBundle.swift

import OpalHedgeBitcoinCash
import OpalHedgeClient
import OpalHedgeCore

extension OpalHedgeClientContext {
    public func createAnyHedgeContractBundle(
        from creationContext: OpalHedgeCoreContractCreationContext,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractBundle {
        let plan = try OpalHedgeCoreContractPlan(from: creationContext)

        return try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: plan,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        )
    }

    public func createAnyHedgeContractFundingRequest(
        from creationContext: OpalHedgeCoreContractCreationContext,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractFundingRequest {
        try createAnyHedgeContractBundle(
            from: creationContext,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        ).fundingRequest
    }
}
