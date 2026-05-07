// OpalHedgeBitcoinCashAnyHedgeContractSettlementSummaryValidator.swift

import Foundation
import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractSettlementSummaryValidator {
    @Test("Creates AnyHedge contract settlement summary")
    func createAnyHedgeContractSettlementSummary() throws {
        let record = try makeSettlementRecord()
        let summary = record.settlementSummary
        let directSummary = OpalHedge.BitcoinCash.AnyHedgeContractSettlementSummary(
            settlementRecord: record
        )

        #expect(summary == directSummary)
        #expect(summary.settlementKind == .maturation)
        #expect(summary.fundingTransactionHash == String(repeating: "1", count: 64))
        #expect(summary.fundingOutputIndex == 0)
        #expect(summary.fundingSatoshis == 5_651_049)
        #expect(summary.settlementTransactionHash == String(repeating: "2", count: 64))
        #expect(summary.settlementPrice == 23_500)
        #expect(
            summary.settlementPayoutAmounts == OpalHedge.BitcoinCash
                .AnyHedgeContractSettlementPayoutAmounts(
                    hedgePayoutInSatoshis: 4_255_319,
                    longPayoutInSatoshis: 1_394_398
                )
        )
        #expect(summary.hedgePayoutInSatoshis == 4_255_319)
        #expect(summary.longPayoutInSatoshis == 1_394_398)
        #expect(summary.minerFeeInSatoshis == 1_332)
        #expect(summary.totalPayoutInSatoshis == 5_649_717)
        #expect(summary.dataDocument == record.dataDocument)
        #expect(summary.previousOracleMessageHex == OpalHedgeFixtureData
            .startingOracleMessageHex)
        #expect(summary.previousOracleSignatureHex == OpalHedgeFixtureData
            .startingOracleSignatureHex)
        #expect(summary.previousOracleMessageTimestamp == 615_643)
        #expect(summary.previousOracleMessageSequence == 1)
        #expect(summary.settlementOracleMessageHex == (try OpalHedgeContractFixtureBuilder
            .makeSettlementOracleProof(
                messageTimestamp: 6_663_643,
                messageSequence: 2,
                priceSequence: 2,
                priceValue: 23_500
            )).messageHex)
        #expect(summary.settlementOracleSignatureHex == OpalHedgeFixtureData
            .startingOracleSignatureHex)
        #expect(summary.settlementOracleMessageTimestamp == 6_663_643)
        #expect(summary.settlementOracleMessageSequence == 2)
    }

    @Test("Creates AnyHedge liquidation settlement summary")
    func createAnyHedgeLiquidationSettlementSummary() throws {
        let record = try makeSettlementRecord(
            settlementTimestamp: 615_644,
            settlementPrice: 17_500
        )
        let summary = record.settlementSummary

        #expect(summary.settlementKind == .liquidation)
        #expect(summary.settlementPrice == 17_500)
        #expect(
            summary.settlementPayoutAmounts == OpalHedge.BitcoinCash
                .AnyHedgeContractSettlementPayoutAmounts(
                    hedgePayoutInSatoshis: 5_649_717,
                    longPayoutInSatoshis: 1_332
                )
        )
        #expect(summary.hedgePayoutInSatoshis == 5_649_717)
        #expect(summary.longPayoutInSatoshis == 1_332)
        #expect(summary.minerFeeInSatoshis == 0)
        #expect(summary.totalPayoutInSatoshis == 5_651_049)
        #expect(summary.settlementOracleMessageTimestamp == 615_644)
    }

    @Test("Reconstructs AnyHedge contract settlement summary from data document")
    func reconstructAnyHedgeContractSettlementSummaryFromDataDocument() throws {
        let record = try makeSettlementRecord()
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: record.dataDocument.jsonText
        )
        let summary = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementSummary(
            dataDocument: decodedDocument
        )

        #expect(summary == record.settlementSummary)
        #expect(summary.dataDocument == decodedDocument)
        #expect(summary.settlementKind == .maturation)
        #expect(summary.settlementPrice == 23_500)
    }

    @Test("Rejects AnyHedge contract settlement summary without settlement data")
    func rejectAnyHedgeContractSettlementSummaryWithoutSettlementData() throws {
        let fundingRecord = try makeFundingRecord()
        let error = captureSettlementRecordError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementSummary(
                dataDocument: fundingRecord.dataDocument
            )
        }

        #expect(error == .missingSettlement(index: 0))
    }

    @Test("Reads AnyHedge maturation automated payout data from settlement summary document")
    func readAnyHedgeMaturationAutomatedPayoutDataFromSettlementSummaryDocument() throws {
        let summary = try makeSettlementRecord().settlementSummary

        try validateAutomatedPayoutData(for: summary)
    }

    @Test("Reads AnyHedge liquidation automated payout data from settlement summary document")
    func readAnyHedgeLiquidationAutomatedPayoutDataFromSettlementSummaryDocument() throws {
        let summary = try makeSettlementRecord(
            settlementTimestamp: 615_644,
            settlementPrice: 17_500
        ).settlementSummary

        try validateAutomatedPayoutData(for: summary)
    }

    private func makeSettlementRecord(
        settlementTimestamp: Int64 = 6_663_643,
        settlementPrice: Int64 = 23_500
    ) throws -> OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecord {
        let request = try makeFundingRecord().createSettlementRequest(
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof(
                    messageTimestamp: settlementTimestamp,
                    priceValue: settlementPrice
                )
        )

        return try request.createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
    }

    private func makeFundingRecord() throws -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord {
        let bundle = try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )

        return try bundle.createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
    }

    private func documentDictionary(
        for document: OpalHedge.Core.ContractDataDocument
    ) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(
            with: document.utf8Data
        ) as? [String: Any])
    }

    private func validateAutomatedPayoutData(
        for summary: OpalHedge.BitcoinCash.AnyHedgeContractSettlementSummary
    ) throws {
        let dictionary = try documentDictionary(for: summary.dataDocument)
        let fundings = try #require(dictionary["fundings"] as? [[String: Any]])
        let funding = try #require(fundings.first)
        let settlement = try #require(funding["settlement"] as? [String: Any])

        #expect(Set(settlement.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractAutomatedPayoutV1FieldNames)
        #expect(funding["fundingTransactionHash"] as? String == summary.fundingTransactionHash)
        #expect(funding["fundingOutputIndex"] as? Int == Int(summary.fundingOutputIndex))
        #expect(funding["fundingSatoshis"] as? Int == Int(summary.fundingSatoshis))
        #expect(settlement["settlementTransactionHash"] as? String ==
            summary.settlementTransactionHash)
        #expect(settlement["settlementType"] as? String == summary.settlementKind.rawValue)
        #expect(settlement["settlementPrice"] as? Int == Int(summary.settlementPrice))
        #expect(settlement["previousMessage"] as? String == summary.previousOracleMessageHex)
        #expect(settlement["previousSignature"] as? String == summary.previousOracleSignatureHex)
        #expect(settlement["settlementMessage"] as? String == summary.settlementOracleMessageHex)
        #expect(settlement["settlementSignature"] as? String ==
            summary.settlementOracleSignatureHex)
        #expect(settlement["hedgePayoutInSatoshis"] as? Int ==
            Int(summary.hedgePayoutInSatoshis))
        #expect(settlement["longPayoutInSatoshis"] as? Int ==
            Int(summary.longPayoutInSatoshis))
    }

    private func captureSettlementRecordError(
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
