// OpalHedgeBitcoinCashAnyHedgeContractFundingStateValidator.swift

import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractFundingStateValidator {
    @Test("Represents unfunded AnyHedge contract funding state")
    func representUnfundedAnyHedgeContractFundingState() throws {
        let bundle = try makeBundle()
        let state = bundle.fundingState

        #expect(state == .unfunded(bundle.fundingRequest))
        #expect(!state.isFunded)
        #expect(state.fundingOutput == bundle.fundingOutput)
        #expect(state.domainDataDocument == bundle.dataDocument)
        #expect(state.domainFundingRequest == bundle.fundingRequest)
        #expect(state.domainFundingRecord == nil)
        #expect(state.domainFunding == nil)
    }

    @Test("Represents funded AnyHedge contract funding state")
    func representFundedAnyHedgeContractFundingState() throws {
        let bundle = try makeBundle()
        let record = try bundle.createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let state = record.fundingState

        #expect(state == .funded(record))
        #expect(state.isFunded)
        #expect(state.fundingOutput == record.fundingOutput)
        #expect(state.domainDataDocument == record.dataDocument)
        #expect(state.domainFundingRequest == nil)
        #expect(state.domainFundingRecord == record)
        #expect(state.domainFunding == record.funding)
    }

    private func makeBundle() throws -> OpalHedgeBitcoinCashAnyHedgeContractBundle {
        try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )
    }
}
