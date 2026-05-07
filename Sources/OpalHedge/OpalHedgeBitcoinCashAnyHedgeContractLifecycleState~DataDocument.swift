// OpalHedgeBitcoinCashAnyHedgeContractLifecycleState~DataDocument.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

extension OpalHedgeBitcoinCashAnyHedgeContractLifecycleState {
    public init(
        dataDocument: OpalHedgeCoreContractDataDocument,
        fundingIndex: Int = 0,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws {
        let fundings = dataDocument.draftData.fundings

        guard !fundings.isEmpty else {
            guard fundingIndex == 0 else {
                throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                    .missingFundingRecord(index: fundingIndex)
            }

            let fundingRequest = try OpalHedgeBitcoinCashAnyHedgeContractFundingRequest(
                dataDocument: dataDocument,
                network: network,
                scriptBytecode: scriptBytecode
            )
            self = .unfunded(fundingRequest)
            return
        }

        guard fundings.indices.contains(fundingIndex) else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .missingFundingRecord(index: fundingIndex)
        }

        let funding = fundings[fundingIndex]
        if funding.settlement == nil {
            let fundingRecord = try OpalHedgeBitcoinCashAnyHedgeContractFundingRecord(
                dataDocument: dataDocument,
                fundingIndex: fundingIndex,
                network: network,
                scriptBytecode: scriptBytecode
            )
            self = .funded(fundingRecord)
        } else {
            let settlementRecord = try OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord(
                dataDocument: dataDocument,
                fundingIndex: fundingIndex,
                network: network,
                scriptBytecode: scriptBytecode
            )
            self = .settled(settlementRecord)
        }
    }
}
