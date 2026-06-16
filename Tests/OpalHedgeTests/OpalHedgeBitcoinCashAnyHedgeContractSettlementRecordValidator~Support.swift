// OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordValidator~Support.swift

import Foundation
import Testing
import OpalHedge
import OpalHedgeBitcoinCash

extension OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordValidator {
    func makeSettlementRequest() throws
        -> OpalHedge.BitcoinCash.AnyHedgeContractSettlementRequest {
        try makeSettlementRequest(fundingRecord: makeFundingRecord())
    }

    func makeSettlementRequest(
        fundingRecord: OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord
    ) throws -> OpalHedge.BitcoinCash.AnyHedgeContractSettlementRequest {
        return try fundingRecord.createSettlementRequest(
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeVerifiedStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeVerifiedSettlementOracleProof(
                    messageTimestamp: 6_663_643,
                    priceValue: 23_500
                )
        )
    }

    func makeFundingRecord() throws -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord {
        let bundle = try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeContractFixtureBuilder.makeVerifiedCreationContext()
            )
        )

        return try bundle.createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
    }

    func makeDocumentDictionary(
        for document: OpalHedge.Core.ContractDataDocument
    ) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(
            with: document.utf8Data
        ) as? [String: Any])
    }

    func captureSettlementRecordError(
        _ operation: () throws -> Void
    ) -> OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecordError? {
        do {
            try operation()
        } catch let error as OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecordError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }
}
