// OpalHedgeBitcoinCashAnyHedgeContractFundingRequestValidator.swift

import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractFundingRequestValidator {
    @Test("Creates AnyHedge contract funding request from bundle")
    func createAnyHedgeContractFundingRequestFromBundle() throws {
        let bundle = try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )
        let request = bundle.fundingRequest

        #expect(request.fundingOutput == bundle.fundingOutput)
        #expect(request.contractDataDocument == bundle.dataDocument)
        #expect(request.redeemScriptBytecode == bundle.bytecode.redeemScriptBytecode)
        #expect(request.contractScriptArtifact == .anyHedgeV0_12)
        #expect(request.fundingOutput.satoshis == 5_651_049)
        #expect(request.redeemScriptBytecode.count == 343)
    }

    @Test("Creates AnyHedge contract funding request from client context")
    func createAnyHedgeContractFundingRequestFromClientContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let request = try clientContext.createAnyHedgeContractFundingRequest(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let bundle = try clientContext.createAnyHedgeContractBundle(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        #expect(request == bundle.fundingRequest)
        #expect(request.fundingOutput.contractAddress.rawValue == "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx")
        #expect(request.contractDataDocument.jsonText == OpalHedgeFixtureData
            .upstreamHedgeTenWeekContractDataDocumentJsonText)
    }
}
