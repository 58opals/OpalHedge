// OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordValidator {
    @Test("Creates AnyHedge contract settlement record")
    func createAnyHedgeContractSettlementRecord() throws {
        let request = try makeSettlementRequest()
        let record = try request.createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let directRecord = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecord(
            settlementRequest: request,
            settlementTransactionHash: String(repeating: "2", count: 64)
        )

        #expect(record == directRecord)
        #expect(record.settlementRequest == request)
        #expect(record.fundingRecord == request.fundingRecord)
        #expect(record.settlementTransactionHash == String(repeating: "2", count: 64))
        #expect(record.settlement.kind == .maturation)
        #expect(
            record.settlement.payoutAmounts == OpalHedge.Core.ContractSettlementPayoutAmounts(
                shortPayoutInSatoshis: 4_255_319,
                longPayoutInSatoshis: 1_394_398
            )
        )
        #expect(record.settlement.shortPayoutInSatoshis == 4_255_319)
        #expect(record.settlement.longPayoutInSatoshis == 1_394_398)
        #expect(record.settlement.totalPayoutInSatoshis == 5_649_717)
        #expect(record.settlement.settlementPrice == 23_500)
        #expect(record.funding.settlement == record.settlement)
        #expect(record.draftData.fundings.last == record.funding)
        #expect(record.draftData.fees == request.fundingRecord.draftData.fees)
    }

    @Test("Writes AnyHedge automated payout data")
    func writeAnyHedgeAutomatedPayoutData() throws {
        let record = try makeSettlementRequest().createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let dictionary = try documentDictionary(for: record.dataDocument)
        let fundings = try #require(dictionary["fundings"] as? [[String: Any]])
        let funding = try #require(fundings.first)
        let settlement = try #require(funding["settlement"] as? [String: Any])

        #expect(Set(settlement.keys) == OpalHedgeFixtureReferenceData
            .anyHedgeContractAutomatedPayoutV1FieldNames)
        #expect(settlement["settlementTransactionHash"] as? String == String(
            repeating: "2",
            count: 64
        ))
        #expect(settlement["settlementType"] as? String == "maturation")
        #expect(settlement["hedgePayoutInSatoshis"] as? Int == 4_255_319)
        #expect(settlement["longPayoutInSatoshis"] as? Int == 1_394_398)
        #expect(settlement["settlementPrice"] as? Int == 23_500)
        #expect(settlement["previousMessage"] as? String == OpalHedgeFixtureData
            .startingOracleMessageHex)
        #expect(settlement["previousSignature"] as? String == OpalHedgeFixtureData
            .startingOracleSignatureHex)
    }

    @Test("Rejects invalid AnyHedge contract settlement record")
    func rejectInvalidAnyHedgeContractSettlementRecord() throws {
        let error = captureSettlementRecordError {
            _ = try makeSettlementRequest().createSettlementRecord(
                settlementTransactionHash: "zz"
            )
        }

        #expect(error == .invalidSettlementTransactionHash("zz"))
    }

    private func makeSettlementRequest() throws
        -> OpalHedge.BitcoinCash.AnyHedgeContractSettlementRequest {
        let fundingRecord = try makeFundingRecord()

        return try fundingRecord.createSettlementRequest(
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof(
                    messageTimestamp: 6_663_643,
                    priceValue: 23_500
                )
        )
    }

    private func makeFundingRecord() throws -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord {
        let bundle = try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
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
