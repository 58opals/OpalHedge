// OpalHedgeBitcoinCashAnyHedgeContractFundingStateValidator.swift

import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractFundingStateValidator {
    @Test("Represents unfunded AnyHedge contract funding state")
    func representUnfundedAnyHedgeContractFundingState() throws {
        let bundle = try makeBundle()
        let state = bundle.fundingState

        #expect(state == .unfunded(bundle.fundingRequest))
        #expect(!state.isFunded)
        #expect(state.fundingOutput == bundle.fundingOutput)
        #expect(state.dataDocument == bundle.dataDocument)
        #expect(state.fundingRequest == bundle.fundingRequest)
        #expect(state.fundingRecord == nil)
        #expect(state.funding == nil)
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
        #expect(state.dataDocument == record.dataDocument)
        #expect(state.fundingRequest == nil)
        #expect(state.fundingRecord == record)
        #expect(state.funding == record.funding)
    }

    private func makeBundle() throws -> OpalHedge.BitcoinCash.AnyHedgeContractBundle {
        try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )
    }
}
