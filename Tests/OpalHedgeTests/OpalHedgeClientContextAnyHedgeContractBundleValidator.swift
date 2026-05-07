// OpalHedgeClientContextAnyHedgeContractBundleValidator.swift

import Testing
import OpalHedge

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
        let expectedBundle = try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
            plan: expectedPlan
        )

        #expect(bundle == expectedBundle)
        #expect(bundle.contractAddress.rawValue == "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx")
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
            address: OpalHedgeFixtureData.longPayoutAddress,
            satoshis: 1_000
        )
        let bundle = try OpalHedge.Client.Context()
            .createAnyHedgeContractBundle(
                from: OpalHedgeFixtureData.contractCreationContext,
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
