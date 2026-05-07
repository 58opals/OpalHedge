// OpalHedgeBitcoinCashAnyHedgeContractLifecycleStateValidator.swift

import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractLifecycleStateValidator {
    @Test("Represents unfunded AnyHedge contract lifecycle state")
    func representUnfundedAnyHedgeContractLifecycleState() throws {
        let bundle = try makeBundle()
        let state = bundle.lifecycleState

        #expect(state == .unfunded(bundle.fundingRequest))
        #expect(state == OpalHedge.BitcoinCash.AnyHedgeContractLifecycleState(
            bundle: bundle
        ))
        #expect(!state.isFunded)
        #expect(!state.isSettled)
        #expect(state.fundingOutput == bundle.fundingOutput)
        #expect(state.dataDocument == bundle.dataDocument)
        #expect(state.fundingRequest == bundle.fundingRequest)
        #expect(state.fundingRecord == nil)
        #expect(state.settlementRecord == nil)
        #expect(state.settlementRequest == nil)
        #expect(state.funding == nil)
        #expect(state.settlement == nil)
        #expect(state.settlementDataDocument == nil)
        #expect(state.settlementSummary == nil)
    }

    @Test("Represents funded AnyHedge contract lifecycle state")
    func representFundedAnyHedgeContractLifecycleState() throws {
        let record = try makeFundingRecord()
        let state = record.lifecycleState

        #expect(state == .funded(record))
        #expect(state.isFunded)
        #expect(!state.isSettled)
        #expect(state.fundingOutput == record.fundingOutput)
        #expect(state.dataDocument == record.dataDocument)
        #expect(state.fundingRequest == nil)
        #expect(state.fundingRecord == record)
        #expect(state.settlementRecord == nil)
        #expect(state.settlementRequest == nil)
        #expect(state.funding == record.funding)
        #expect(state.settlement == nil)
        #expect(state.settlementDataDocument == nil)
        #expect(state.settlementSummary == nil)
    }

    @Test("Represents settled AnyHedge contract lifecycle state")
    func representSettledAnyHedgeContractLifecycleState() throws {
        let record = try makeSettlementRecord()
        let state = record.lifecycleState

        #expect(state == .settled(record))
        #expect(state.isFunded)
        #expect(state.isSettled)
        #expect(state.fundingOutput == record.fundingRecord.fundingOutput)
        #expect(state.dataDocument == record.dataDocument)
        #expect(state.fundingRequest == nil)
        #expect(state.fundingRecord == record.fundingRecord)
        #expect(state.settlementRecord == record)
        #expect(state.settlementRequest == record.settlementRequest)
        #expect(state.funding == record.funding)
        #expect(state.settlement == record.settlement)
        #expect(state.settlementDataDocument == record.dataDocument)
        #expect(state.settlementSummary == record.settlementSummary)
        #expect(state.settlementSummary?.dataDocument == record.dataDocument)
    }

    @Test("Reconstructs AnyHedge contract lifecycle state from data documents")
    func reconstructAnyHedgeContractLifecycleStateFromDataDocuments() throws {
        let bundle = try makeBundle()
        let fundingRecord = try makeFundingRecord()
        let settlementRecord = try makeSettlementRecord()

        let unfundedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: bundle.dataDocument.jsonText
        )
        let fundedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: fundingRecord.dataDocument.jsonText
        )
        let settledDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: settlementRecord.dataDocument.jsonText
        )

        #expect(try OpalHedge.BitcoinCash.AnyHedgeContractLifecycleState(
            dataDocument: unfundedDocument
        ) == .unfunded(bundle.fundingRequest))
        #expect(try OpalHedge.BitcoinCash.AnyHedgeContractLifecycleState(
            dataDocument: fundedDocument
        ) == .funded(fundingRecord))
        #expect(try OpalHedge.BitcoinCash.AnyHedgeContractLifecycleState(
            dataDocument: settledDocument
        ) == .settled(settlementRecord))
    }

    @Test("Creates AnyHedge contract lifecycle state from data document with client context")
    func createAnyHedgeContractLifecycleStateFromDataDocumentWithClientContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let settlementRecord = try makeSettlementRecord()
        let settledDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: settlementRecord.dataDocument.jsonText
        )

        let state = try clientContext.createAnyHedgeContractLifecycleState(
            from: settledDocument
        )

        #expect(state == .settled(settlementRecord))
        #expect(state.settlementRecord == settlementRecord)
        #expect(state.settlementSummary == settlementRecord.settlementSummary)
    }

    @Test("Rejects missing AnyHedge contract lifecycle funding index")
    func rejectMissingAnyHedgeContractLifecycleFundingIndex() throws {
        let fundingRecord = try makeFundingRecord()
        let fundedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: fundingRecord.dataDocument.jsonText
        )

        let error = captureFundingRecordError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractLifecycleState(
                dataDocument: fundedDocument,
                fundingIndex: 1
            )
        }

        #expect(error == .missingFundingRecord(index: 1))
    }

    private func makeBundle() throws -> OpalHedge.BitcoinCash.AnyHedgeContractBundle {
        try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )
    }

    private func makeFundingRecord() throws -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecord {
        try makeBundle().createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
    }

    private func makeSettlementRecord() throws
        -> OpalHedge.BitcoinCash.AnyHedgeContractSettlementRecord {
        let request = try makeFundingRecord().createSettlementRequest(
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof()
        )

        return try request.createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
    }

    private func captureFundingRecordError(
        _ operation: () throws -> Void
    ) -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecordError? {
        do {
            try operation()
        } catch let error as OpalHedge.BitcoinCash.AnyHedgeContractFundingRecordError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }
}
