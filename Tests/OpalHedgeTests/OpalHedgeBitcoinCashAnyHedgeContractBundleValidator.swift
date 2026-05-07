// OpalHedgeBitcoinCashAnyHedgeContractBundleValidator.swift

import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractBundleValidator {
    @Test("Creates AnyHedge contract bundle from Core contract plan")
    func createAnyHedgeContractBundleFromCoreContractPlan() throws {
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let bundle = try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
            plan: plan
        )
        let expectedParameterData = try OpalHedge.BitcoinCash
            .AnyHedgeContractParameterData(from: plan)
        let expectedBytecode = try OpalHedge.BitcoinCash
            .AnyHedgeContractBytecode(from: plan)

        #expect(bundle.plan == plan)
        #expect(bundle.draftData.parameters == plan.parameters)
        #expect(bundle.draftData.metadata == plan.metadata)
        #expect(bundle.parameterData == expectedParameterData)
        #expect(bundle.bytecode == expectedBytecode)
        #expect(bundle.bytecode.redeemScriptBytecode.count == 343)
        #expect(bundle.fundingOutput.satoshis == 5_651_049)
        #expect(bundle.contractAddress.rawValue == "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx")
        #expect(bundle.dataDocument.jsonText == OpalHedgeFixtureData
            .upstreamHedgeTenWeekContractDataDocumentJsonText)
    }

    @Test("Includes network funding and fee data in AnyHedge contract bundle")
    func includeNetworkFundingAndFeeDataInAnyHedgeContractBundle() throws {
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
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
        let bundle = try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
            plan: plan,
            network: .regtest,
            fundings: [funding],
            fees: [feeData]
        )

        #expect(bundle.contractAddress.rawValue == "bchreg:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsr6pyr2gu")
        #expect(bundle.draftData.fundings == [funding])
        #expect(bundle.draftData.fees == [feeData])
        #expect(bundle.dataDocument.jsonText.contains("\"fundingTransactionHash\""))
        #expect(bundle.dataDocument.jsonText.contains("\"satoshis\":1000"))
    }
}
