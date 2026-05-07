// OpalHedgeClientContext+AnyHedgeContractSettlementRecord.swift

import OpalHedgeBitcoinCash
import OpalHedgeClient
import OpalHedgeCore

extension OpalHedgeClientContext {
    public func createAnyHedgeContractSettlementRecord(
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
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord {
        let settlementRequest = try createAnyHedgeContractSettlementRequest(
            from: creationContext,
            fundingTransactionHash: fundingTransactionHash,
            fundingOutputIndex: fundingOutputIndex,
            fundingSatoshis: fundingSatoshis,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        )

        return try settlementRequest.createSettlementRecord(
            settlementTransactionHash: settlementTransactionHash
        )
    }

    public func createAnyHedgeContractSettlementRecord(
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
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord {
        let settlementRequest = try createAnyHedgeContractSettlementRequest(
            from: plan,
            fundingTransactionHash: fundingTransactionHash,
            fundingOutputIndex: fundingOutputIndex,
            fundingSatoshis: fundingSatoshis,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof,
            network: network,
            scriptBytecode: scriptBytecode,
            fundings: fundings,
            fees: fees
        )

        return try settlementRequest.createSettlementRecord(
            settlementTransactionHash: settlementTransactionHash
        )
    }

    public func createAnyHedgeContractSettlementRecord(
        from dataDocument: OpalHedgeCoreContractDataDocument,
        fundingIndex: Int = 0,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord {
        try OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord(
            dataDocument: dataDocument,
            fundingIndex: fundingIndex,
            network: network,
            scriptBytecode: scriptBytecode
        )
    }
}
