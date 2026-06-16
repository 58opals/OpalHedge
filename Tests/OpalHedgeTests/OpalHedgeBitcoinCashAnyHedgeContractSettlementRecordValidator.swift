// OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordValidator.swift

import Foundation
import Testing
import OpalHedge
import OpalHedgeBitcoinCash

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
        #expect(record.fundingRecord == request.domainFundingRecord)
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
        #expect(record.draftData.fees == request.domainFundingRecord.draftData.fees)
    }

    @Test("Writes AnyHedge automated payout data")
    func writeAnyHedgeAutomatedPayoutData() throws {
        let record = try makeSettlementRequest().createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let dictionary = try makeDocumentDictionary(for: record.dataDocument)
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
        #expect(settlement["previousSignature"] as? String ==
            record.settlement.previousSignatureHex)
    }

    @Test("Reconstructs AnyHedge contract settlement record from data document")
    func reconstructAnyHedgeContractSettlementRecordFromDataDocument() throws {
        let record = try makeSettlementRequest().createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: record.dataDocument.jsonText
        )
        let reconstructedRecord = try OpalHedge.BitcoinCash
            .AnyHedgeContractSettlementRecord(
                dataDocument: decodedDocument
            )

        #expect(reconstructedRecord == record)
        #expect(reconstructedRecord.settlementSummary == record.settlementSummary)
        #expect(reconstructedRecord.lifecycleState == record.lifecycleState)
    }

    @Test("Rejects unverified settlement oracle signature in data document")
    func rejectUnverifiedSettlementOracleSignatureInDataDocument() throws {
        let record = try makeSettlementRequest().createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let signatureHex = try #require(record.settlement.settlementSignatureHex)
        let tamperedSignatureHex = "0" + String(signatureHex.dropFirst())
        let tamperedJsonText = try OpalHedgeContractDataDocumentMutationTool
            .makeJsonText(
                replacingFieldAt: .firstFundingSettlement("settlementSignature"),
                with: tamperedSignatureHex,
                in: record.dataDocument.jsonText
            )
        let tamperedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: tamperedJsonText
        )

        var didRejectTamperedProof = false
        do {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecord(
                dataDocument: tamperedDocument
            )
        } catch {
            didRejectTamperedProof = true
        }

        #expect(didRejectTamperedProof)
    }

    @Test("Settles selected funding when duplicate funding records exist")
    func settleSelectedFundingWhenDuplicateFundingRecordsExist() throws {
        let fundingRecord = try makeFundingRecord()
        let duplicateFundingDataDocument = try OpalHedge.Core.ContractDataDocument(
            draftData: OpalHedge.Core.ContractDraftData(
                parameters: fundingRecord.draftData.parameters,
                metadata: fundingRecord.draftData.metadata,
                fundings: [
                    fundingRecord.funding,
                    fundingRecord.funding
                ],
                fees: fundingRecord.draftData.fees
            )
        )
        let firstFundingRecord = try OpalHedge.BitcoinCash
            .AnyHedgeContractFundingRecord(
                dataDocument: duplicateFundingDataDocument,
                fundingIndex: 0
            )
        let record = try makeSettlementRequest(
            fundingRecord: firstFundingRecord
        ).createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )

        #expect(record.draftData.fundings[0].settlement == record.settlement)
        #expect(record.draftData.fundings[1].settlement == nil)
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

    @Test("Rejects invalid AnyHedge contract settlement record data document")
    func rejectInvalidAnyHedgeContractSettlementRecordDataDocument() throws {
        let fundingRecord = try makeFundingRecord()
        let missingSettlementError = captureSettlementRecordError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecord(
                dataDocument: fundingRecord.dataDocument
            )
        }
        let record = try makeSettlementRequest().createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let invalidPayoutDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: record.dataDocument.jsonText.replacingOccurrences(
                of: #""hedgePayoutInSatoshis":4255319"#,
                with: #""hedgePayoutInSatoshis":4255318"#
            )
        )
        let actualSettlement = try #require(invalidPayoutDocument.draftData
            .fundings.first?.settlement)
        let invalidPayoutError = captureSettlementRecordError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecord(
                dataDocument: invalidPayoutDocument
            )
        }

        #expect(missingSettlementError == .missingSettlement(index: 0))
        #expect(
            invalidPayoutError == .inconsistentSettlement(
                expected: record.settlement,
                actual: actualSettlement
            )
        )
    }
}
