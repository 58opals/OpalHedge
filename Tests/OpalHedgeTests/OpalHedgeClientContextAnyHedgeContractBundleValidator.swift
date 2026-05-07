// OpalHedgeClientContextAnyHedgeContractBundleValidator.swift

import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeClientContextAnyHedgeContractBundleValidator {
    @Test("Creates AnyHedge contract bundle from creation context")
    func createAnyHedgeContractBundleFromCreationContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let bundle = try clientContext.createAnyHedgeContractBundle(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let expectedPlan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let expectedBundle = try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: expectedPlan
        )

        #expect(bundle == expectedBundle)
        #expect(bundle.contractAddress.rawValue == "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx")
    }

    @Test("Creates AnyHedge contract bundle from contract plan")
    func createAnyHedgeContractBundleFromContractPlan() throws {
        let clientContext = OpalHedge.Client.Context()
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let bundle = try clientContext.createAnyHedgeContractBundle(
            from: plan
        )
        let expectedBundle = try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: plan
        )

        #expect(bundle == expectedBundle)
        #expect(bundle.plan == plan)
        #expect(bundle.dataDocument.jsonText == OpalHedgeFixtureData
            .upstreamHedgeTenWeekContractDataDocumentJsonText)
    }

    @Test("Passes AnyHedge contract bundle options through client context")
    func passAnyHedgeContractBundleOptionsThroughClientContext() throws {
        let funding = OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 1,
            fundingSatoshis: 5_651_049
        )
        let feeData = OpalHedge.Core.ContractFeeData(
            name: "settlement",
            description: "Settlement service fee",
            address: OpalHedgeFixtureData.longRegtestPayoutAddress,
            satoshis: 1_000
        )
        let creationContext = OpalHedgeContractFixtureBuilder.makeCreationContext(
            shortPayoutAddress: OpalHedgeFixtureData.shortRegtestPayoutAddress,
            longPayoutAddress: OpalHedgeFixtureData.longRegtestPayoutAddress
        )
        let bundle = try OpalHedge.Client.Context()
            .createAnyHedgeContractBundle(
                from: creationContext,
                network: .regtest,
                fundings: [funding],
                fees: [feeData]
            )

        #expect(bundle.contractAddress.rawValue == "bchreg:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsr6pyr2gu")
        #expect(bundle.draftData.fundings == [funding])
        #expect(bundle.draftData.fees == [feeData])
        #expect(bundle.dataDocument.jsonText.contains("\"satoshis\":1000"))
    }
}
