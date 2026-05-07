// OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary~DataDocument.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

extension OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary {
    public init(
        dataDocument: OpalHedgeCoreContractDataDocument,
        fundingIndex: Int = 0,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws {
        let settlementRecord = try OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord(
            dataDocument: dataDocument,
            fundingIndex: fundingIndex,
            network: network,
            scriptBytecode: scriptBytecode
        )

        self.init(settlementRecord: settlementRecord)
    }
}
