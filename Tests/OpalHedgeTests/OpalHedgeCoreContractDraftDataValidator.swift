// OpalHedgeCoreContractDraftDataValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractDraftDataValidator {
    @Test("Creates draft data from contract plan")
    func createDraftDataFromContractPlan() throws {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let draftData = OpalHedge.Core.ContractDraftData(plan: plan)

        #expect(draftData.parameters == plan.parameters)
        #expect(draftData.metadata == plan.metadata)
        #expect(draftData.fundings.isEmpty)
        #expect(draftData.fees.isEmpty)
    }

    @Test("Creates draft data from explicit components")
    func createDraftDataFromExplicitComponents() throws {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let funding = OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "0", count: 64),
            fundingOutputIndex: 0,
            fundingSatoshis: 5_651_049
        )
        let feeData = OpalHedge.Core.ContractFeeData(
            name: "settlement",
            description: "Settlement service fee",
            address: OpalHedgeFixtureData.shortPayoutAddress,
            satoshis: 1_000
        )
        let draftData = OpalHedge.Core.ContractDraftData(
            parameters: plan.parameters,
            metadata: plan.metadata,
            fundings: [funding],
            fees: [feeData]
        )

        #expect(draftData.parameters == plan.parameters)
        #expect(draftData.metadata == plan.metadata)
        #expect(draftData.fundings == [funding])
        #expect(draftData.fees == [feeData])
    }
}
