// OpalHedgeBitcoinCashAnyHedgeContractLifecycleStateValidator.swift

import Testing
import OpalHedge
import OpalHedgeBitcoinCash

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
        #expect(state.domainDataDocument == bundle.dataDocument)
        #expect(state.domainFundingRequest == bundle.fundingRequest)
        #expect(state.domainFundingRecord == nil)
        #expect(state.domainSettlementRecord == nil)
        #expect(state.domainSettlementRequest == nil)
        #expect(state.domainFunding == nil)
        #expect(state.domainSettlement == nil)
        #expect(state.domainSettlementDataDocument == nil)
        #expect(state.domainSettlementSummary == nil)
        #expect(state.reviewSnapshot.phase == .unfunded)
        #expect(state.reviewSnapshot.isFunded == false)
    }

    @Test("Represents funded AnyHedge contract lifecycle state")
    func representFundedAnyHedgeContractLifecycleState() throws {
        let record = try makeFundingRecord()
        let state = record.lifecycleState

        #expect(state == .funded(record))
        #expect(state.isFunded)
        #expect(!state.isSettled)
        #expect(state.fundingOutput == record.fundingOutput)
        #expect(state.domainDataDocument == record.dataDocument)
        #expect(state.domainFundingRequest == nil)
        #expect(state.domainFundingRecord == record)
        #expect(state.domainSettlementRecord == nil)
        #expect(state.domainSettlementRequest == nil)
        #expect(state.domainFunding == record.funding)
        #expect(state.domainSettlement == nil)
        #expect(state.domainSettlementDataDocument == nil)
        #expect(state.domainSettlementSummary == nil)
        #expect(state.reviewSnapshot.phase == .funded)
        #expect(state.reviewSnapshot.settlementReviewSummary == nil)
    }

    @Test("Represents settled AnyHedge contract lifecycle state")
    func representSettledAnyHedgeContractLifecycleState() throws {
        let record = try makeSettlementRecord()
        let state = record.lifecycleState

        #expect(state == .settled(record))
        #expect(state.isFunded)
        #expect(state.isSettled)
        #expect(state.fundingOutput == record.fundingRecord.fundingOutput)
        #expect(state.domainDataDocument == record.dataDocument)
        #expect(state.domainFundingRequest == nil)
        #expect(state.domainFundingRecord == record.fundingRecord)
        #expect(state.domainSettlementRecord == record)
        #expect(state.domainSettlementRequest == record.settlementRequest)
        #expect(state.domainFunding == record.funding)
        #expect(state.domainSettlement == record.settlement)
        #expect(state.domainSettlementDataDocument == record.dataDocument)
        #expect(state.domainSettlementSummary == record.settlementSummary)
        #expect(state.domainSettlementSummary?.domainDataDocument == record.dataDocument)
        #expect(state.reviewSnapshot.phase == .settled)
        #expect(state.reviewSnapshot.settlementReviewSummary?.settlementPrice == 23_500)
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
        #expect(state.domainSettlementRecord == settlementRecord)
        #expect(state.domainSettlementSummary == settlementRecord.settlementSummary)
    }

    @Test("Creates unfunded AnyHedge contract lifecycle state from contract plan with client context")
    func createUnfundedAnyHedgeContractLifecycleStateFromContractPlanWithClientContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let state = try clientContext.createAnyHedgeContractLifecycleState(
            from: plan
        )
        let bundle = try clientContext.createAnyHedgeContractBundle(
            from: plan
        )

        #expect(state == bundle.lifecycleState)
        #expect(state.domainFundingRequest == bundle.fundingRequest)
        #expect(!state.isFunded)
    }

    @Test("Creates funded AnyHedge contract lifecycle state from contract plan with funding data")
    func createFundedAnyHedgeContractLifecycleStateFromContractPlanWithFundingData() throws {
        let clientContext = OpalHedge.Client.Context()
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let fundingRecord = try clientContext.createAnyHedgeContractFundingRecord(
            from: plan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let state = try clientContext.createAnyHedgeContractLifecycleState(
            from: plan,
            fundings: [fundingRecord.funding]
        )

        #expect(state == fundingRecord.lifecycleState)
        #expect(state.domainFundingRecord == fundingRecord)
        #expect(state.isFunded)
        #expect(!state.isSettled)
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

    private func makeBundle() throws -> OpalHedgeBitcoinCashAnyHedgeContractBundle {
        try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeContractFixtureBuilder.makeVerifiedCreationContext()
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
                .makeVerifiedStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeVerifiedSettlementOracleProof()
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
