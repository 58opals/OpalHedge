// OpalHedgeClientContext+AnyHedgeContractBundle.swift

import OpalHedgeBitcoinCash
import OpalHedgeClient
import OpalHedgeCore

extension OpalHedgeClientContext {
    package func createAnyHedgeContractBundle(
        from creationContext: OpalHedgeCoreContractCreationContext,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractBundle {
        let plan = try OpalHedgeCoreContractPlan(from: creationContext)

        return try createAnyHedgeContractBundle(
            from: plan,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        )
    }

    package func createAnyHedgeContractBundle(
        from plan: OpalHedgeCoreContractPlan,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractBundle {
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

    public func createAnyHedgeContractFundingRequest(
        from plan: OpalHedgeCoreContractPlan,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractFundingRequest {
        try createAnyHedgeContractBundle(
            from: plan,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        ).fundingRequest
    }

    public func createAnyHedgeContractFundingRequest(
        from dataDocument: OpalHedgeCoreContractDataDocument,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractFundingRequest {
        try OpalHedgeBitcoinCashAnyHedgeContractFundingRequest(
            dataDocument: dataDocument,
            network: network,
            scriptBytecode: scriptBytecode
        )
    }
}
