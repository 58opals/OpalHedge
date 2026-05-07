// OpalHedgeClientContextAnyHedgeContractFundingRecordValidator.swift

import Testing
import OpalHedge

struct OpalHedgeClientContextAnyHedgeContractFundingRecordValidator {
    @Test("Creates AnyHedge contract funding record from client context")
    func createAnyHedgeContractFundingRecordFromClientContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let record = try clientContext.createAnyHedgeContractFundingRecord(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let bundle = try clientContext.createAnyHedgeContractBundle(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let expectedRecord = try bundle.createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )

        #expect(record == expectedRecord)
        #expect(record.fundingOutput == bundle.fundingOutput)
        #expect(record.dataDocument.jsonText.contains("\"fundingTransactionHash\""))
    }

    @Test("Passes AnyHedge contract funding record options through client context")
    func passAnyHedgeContractFundingRecordOptionsThroughClientContext() throws {
        let existingFunding = OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "0", count: 64),
            fundingOutputIndex: 0,
            fundingSatoshis: 5_651_049
        )
        let feeData = OpalHedge.Core.ContractFeeData(
            name: "settlement",
            description: "Settlement service fee",
            address: OpalHedgeFixtureData.longPayoutAddress,
            satoshis: 1_000
        )
        let record = try OpalHedge.Client.Context()
            .createAnyHedgeContractFundingRecord(
                from: OpalHedgeFixtureData.contractCreationContext,
                fundingTransactionHash: String(repeating: "1", count: 64),
                fundingOutputIndex: 1,
                network: .regtest,
                fundings: [existingFunding],
                fees: [feeData]
            )

        #expect(
            record.fundingOutput.contractAddress.rawValue ==
                "bchreg:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsr6pyr2gu"
        )
        #expect(record.draftData.fundings == [existingFunding, record.funding])
        #expect(record.draftData.fees == [feeData])
    }
}
