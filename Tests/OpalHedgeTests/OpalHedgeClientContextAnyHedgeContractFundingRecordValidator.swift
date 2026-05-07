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

    @Test("Creates AnyHedge contract funding record from contract plan")
    func createAnyHedgeContractFundingRecordFromContractPlan() throws {
        let clientContext = OpalHedge.Client.Context()
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let record = try clientContext.createAnyHedgeContractFundingRecord(
            from: plan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let bundle = try clientContext.createAnyHedgeContractBundle(
            from: plan
        )
        let expectedRecord = try bundle.createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )

        #expect(record == expectedRecord)
        #expect(record.draftData.parameters == plan.parameters)
        #expect(record.dataDocument.draftData.fundings == [record.funding])
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
            address: OpalHedgeFixtureData.longRegtestPayoutAddress,
            satoshis: 1_000
        )
        let creationContext = OpalHedgeContractFixtureBuilder.makeCreationContext(
            shortPayoutAddress: OpalHedgeFixtureData.shortRegtestPayoutAddress,
            longPayoutAddress: OpalHedgeFixtureData.longRegtestPayoutAddress
        )
        let record = try OpalHedge.Client.Context()
            .createAnyHedgeContractFundingRecord(
                from: creationContext,
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

    @Test("Creates AnyHedge contract funding record from data document")
    func createAnyHedgeContractFundingRecordFromDataDocument() throws {
        let clientContext = OpalHedge.Client.Context()
        let expectedRecord = try clientContext.createAnyHedgeContractFundingRecord(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: expectedRecord.dataDocument.jsonText
        )
        let record = try clientContext.createAnyHedgeContractFundingRecord(
            from: decodedDocument
        )

        #expect(record == expectedRecord)
    }
}
