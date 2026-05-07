// OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError.swift

import OpalHedgeCore

public enum OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError: Error, Sendable, Equatable {
    case invalidSettlementTransactionHash(String)
    case missingFundingRecord
    case missingDataDocumentFunding(index: Int)
    case missingSettlement(index: Int)
    case missingSettlementField(name: String, fundingIndex: Int)
    case inconsistentSettlement(
        expected: OpalHedgeCoreContractSettlement,
        actual: OpalHedgeCoreContractSettlement
    )
}
