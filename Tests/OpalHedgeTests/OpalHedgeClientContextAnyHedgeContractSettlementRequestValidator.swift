// OpalHedgeClientContextAnyHedgeContractSettlementRequestValidator.swift

import Testing
import OpalHedge

struct OpalHedgeClientContextAnyHedgeContractSettlementRequestValidator {
    @Test("Creates AnyHedge contract settlement request from client context")
    func createAnyHedgeContractSettlementRequestFromClientContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let previousOracleProof = try OpalHedgeContractFixtureBuilder
            .makeStartingSettlementOracleProof()
        let settlementOracleProof = try OpalHedgeContractFixtureBuilder
            .makeSettlementOracleProof()
        let request = try clientContext.createAnyHedgeContractSettlementRequest(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof
        )
        let fundingRecord = try clientContext.createAnyHedgeContractFundingRecord(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let expectedRequest = try fundingRecord.createSettlementRequest(
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof
        )

        #expect(request == expectedRequest)
        #expect(request.domainFundingRecord == fundingRecord)
        #expect(request.settlementKind == .maturation)
        #expect(request.settlementPrice == 23_500)
    }

    @Test("Creates AnyHedge contract settlement request from contract plan")
    func createAnyHedgeContractSettlementRequestFromContractPlan() throws {
        let clientContext = OpalHedge.Client.Context()
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let previousOracleProof = try OpalHedgeContractFixtureBuilder
            .makeStartingSettlementOracleProof()
        let settlementOracleProof = try OpalHedgeContractFixtureBuilder
            .makeSettlementOracleProof()
        let request = try clientContext.createAnyHedgeContractSettlementRequest(
            from: plan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof
        )
        let fundingRecord = try clientContext.createAnyHedgeContractFundingRecord(
            from: plan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let expectedRequest = try fundingRecord.createSettlementRequest(
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof
        )

        #expect(request == expectedRequest)
        #expect(request.domainFundingRecord.draftData.parameters == plan.parameters)
        #expect(request.settlementKind == .maturation)
    }

    @Test("Passes AnyHedge contract settlement request options through client context")
    func passAnyHedgeContractSettlementRequestOptionsThroughClientContext() throws {
        let previousOracleProof = try OpalHedgeContractFixtureBuilder
            .makeStartingSettlementOracleProof()
        let settlementOracleProof = try OpalHedgeContractFixtureBuilder
            .makeSettlementOracleProof(
                messageTimestamp: 615_644,
                priceValue: 17_500
            )
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
        let request = try OpalHedge.Client.Context()
            .createAnyHedgeContractSettlementRequest(
                from: creationContext,
                fundingTransactionHash: String(repeating: "1", count: 64),
                fundingOutputIndex: 1,
                previousOracleProof: previousOracleProof,
                settlementOracleProof: settlementOracleProof,
                network: .regtest,
                fundings: [existingFunding],
                fees: [feeData]
            )

        #expect(request.settlementKind == .liquidation)
        #expect(request.settlementPrice == 17_500)
        #expect(request.domainFundingRecord.draftData.fundings.first == existingFunding)
        #expect(
            request.fundingOutput.contractAddress.rawValue ==
                "bchreg:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsr6pyr2gu"
        )
    }
}
