// OpalHedgeBitcoinCashAnyHedgeContractFundingIndexValidator.swift

import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractFundingIndexValidator {
    @Test("Selects indexed AnyHedge contract funding record from multi-funding document")
    func selectIndexedAnyHedgeContractFundingRecordFromMultiFundingDocument() throws {
        let record = try makeSecondFundingRecord()
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: record.dataDocument.jsonText
        )
        let firstRecord = try OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord(
            dataDocument: decodedDocument,
            fundingIndex: 0
        )
        let secondRecord = try OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord(
            dataDocument: decodedDocument,
            fundingIndex: 1
        )
        let clientRecord = try OpalHedge.Client.Context()
            .createAnyHedgeContractFundingRecord(
                from: decodedDocument,
                fundingIndex: 1
            )

        #expect(firstRecord.funding.fundingTransactionHash == firstFundingTransactionHash)
        #expect(firstRecord.funding.fundingOutputIndex == 0)
        #expect(firstRecord.dataDocument == decodedDocument)
        #expect(secondRecord == record)
        #expect(clientRecord == record)
    }

    @Test("Selects indexed AnyHedge contract settlement record from multi-funding document")
    func selectIndexedAnyHedgeContractSettlementRecordFromMultiFundingDocument() throws {
        let record = try makeSecondSettlementRecord()
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: record.dataDocument.jsonText
        )
        let reconstructedRecord = try OpalHedge.BitcoinCash
            .AnyHedgeContractSettlementRecord(
                dataDocument: decodedDocument,
                fundingIndex: 1
            )
        let clientRecord = try OpalHedge.Client.Context()
            .createAnyHedgeContractSettlementRecord(
                from: decodedDocument,
                fundingIndex: 1
            )
        let missingSettlementError = captureSettlementRecordError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecord(
                dataDocument: decodedDocument,
                fundingIndex: 0
            )
        }

        #expect(reconstructedRecord == record)
        #expect(clientRecord == record)
        #expect(missingSettlementError == .missingSettlement(index: 0))
    }

    @Test("Selects indexed AnyHedge contract lifecycle state from multi-funding document")
    func selectIndexedAnyHedgeContractLifecycleStateFromMultiFundingDocument() throws {
        let record = try makeSecondSettlementRecord()
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: record.dataDocument.jsonText
        )
        let fundedState = try OpalHedge.BitcoinCash.AnyHedgeContractLifecycleState(
            dataDocument: decodedDocument,
            fundingIndex: 0
        )
        let settledState = try OpalHedge.BitcoinCash.AnyHedgeContractLifecycleState(
            dataDocument: decodedDocument,
            fundingIndex: 1
        )
        let clientState = try OpalHedge.Client.Context()
            .createAnyHedgeContractLifecycleState(
                from: decodedDocument,
                fundingIndex: 1
            )

        #expect(fundedState.isFunded)
        #expect(!fundedState.isSettled)
        #expect(fundedState.funding?.fundingTransactionHash == firstFundingTransactionHash)
        #expect(fundedState.settlementRecord == nil)
        #expect(settledState == .settled(record))
        #expect(clientState == .settled(record))
    }

    @Test("Selects indexed AnyHedge contract settlement summary from multi-funding document")
    func selectIndexedAnyHedgeContractSettlementSummaryFromMultiFundingDocument() throws {
        let record = try makeSecondSettlementRecord()
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: record.dataDocument.jsonText
        )
        let summary = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementSummary(
            dataDocument: decodedDocument,
            fundingIndex: 1
        )
        let clientSummary = try OpalHedge.Client.Context()
            .createAnyHedgeContractSettlementSummary(
                from: decodedDocument,
                fundingIndex: 1
            )
        let missingSettlementError = captureSettlementRecordError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractSettlementSummary(
                dataDocument: decodedDocument,
                fundingIndex: 0
            )
        }

        #expect(summary == record.settlementSummary)
        #expect(clientSummary == record.settlementSummary)
        #expect(missingSettlementError == .missingSettlement(index: 0))
    }

    private var firstFundingTransactionHash: String {
        String(repeating: "1", count: 64)
    }

    private var secondFundingTransactionHash: String {
        String(repeating: "2", count: 64)
    }

    private var settlementTransactionHash: String {
        String(repeating: "3", count: 64)
    }

    private func makeBundle(
        fundings: [OpalHedge.Core.ContractFunding] = []
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractBundle {
        try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            ),
            fundings: fundings
        )
    }

    private func makeFirstFundingRecord() throws
        -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord {
        try makeBundle().createFundingRecord(
            fundingTransactionHash: firstFundingTransactionHash,
            fundingOutputIndex: 0
        )
    }

    private func makeSecondFundingRecord() throws
        -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord {
        let firstRecord = try makeFirstFundingRecord()
        let bundle = try makeBundle(fundings: [firstRecord.funding])

        return try bundle.createFundingRecord(
            fundingTransactionHash: secondFundingTransactionHash,
            fundingOutputIndex: 1
        )
    }

    private func makeSecondSettlementRecord() throws
        -> OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecord {
        let request = try makeSecondFundingRecord().createSettlementRequest(
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof()
        )

        return try request.createSettlementRecord(
            settlementTransactionHash: settlementTransactionHash
        )
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
