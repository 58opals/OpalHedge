// OpalHedgeClientContext+AnyHedgeContractSettlementSummary.swift

import OpalHedgeBitcoinCash
import OpalHedgeClient
import OpalHedgeCore

extension OpalHedgeClientContext {
    public func createAnyHedgeContractSettlementSummary(
        from creationContext: OpalHedgeCoreContractCreationContext,
        fundingTransactionHash: String,
        fundingOutputIndex: Int64,
        fundingSatoshis: Int64? = nil,
        previousOracleProof: OpalHedgeCoreContractSettlementOracleProof,
        settlementOracleProof: OpalHedgeCoreContractSettlementOracleProof,
        settlementTransactionHash: String,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary {
        try createAnyHedgeContractSettlementRecord(
            from: creationContext,
            fundingTransactionHash: fundingTransactionHash,
            fundingOutputIndex: fundingOutputIndex,
            fundingSatoshis: fundingSatoshis,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof,
            settlementTransactionHash: settlementTransactionHash,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        ).settlementSummary
    }

    public func createAnyHedgeContractSettlementSummary(
        from plan: OpalHedgeCoreContractPlan,
        fundingTransactionHash: String,
        fundingOutputIndex: Int64,
        fundingSatoshis: Int64? = nil,
        previousOracleProof: OpalHedgeCoreContractSettlementOracleProof,
        settlementOracleProof: OpalHedgeCoreContractSettlementOracleProof,
        settlementTransactionHash: String,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary {
        try createAnyHedgeContractSettlementRecord(
            from: plan,
            fundingTransactionHash: fundingTransactionHash,
            fundingOutputIndex: fundingOutputIndex,
            fundingSatoshis: fundingSatoshis,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof,
            settlementTransactionHash: settlementTransactionHash,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        ).settlementSummary
    }

    public func createAnyHedgeContractSettlementSummary(
        from dataDocument: OpalHedgeCoreContractDataDocument,
        fundingIndex: Int = 0,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary {
        try OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary(
            dataDocument: dataDocument,
            fundingIndex: fundingIndex,
            network: network,
            scriptBytecode: scriptBytecode
        )
    }
}
