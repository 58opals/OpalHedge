// OpalHedgeClientContextAnyHedgeContractSettlementRecordValidator.swift

import Testing
import OpalHedge

struct OpalHedgeClientContextAnyHedgeContractSettlementRecordValidator {
    @Test("Creates AnyHedge contract settlement record from client context")
    func createAnyHedgeContractSettlementRecordFromClientContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let previousOracleProof = try OpalHedgeContractFixtureBuilder
            .makeStartingSettlementOracleProof()
        let settlementOracleProof = try OpalHedgeContractFixtureBuilder
            .makeSettlementOracleProof()
        let record = try clientContext.createAnyHedgeContractSettlementRecord(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof,
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let settlementRequest = try clientContext.createAnyHedgeContractSettlementRequest(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof
        )
        let expectedRecord = try settlementRequest.createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )

        #expect(record == expectedRecord)
        #expect(record.settlementRequest == settlementRequest)
        #expect(record.settlementTransactionHash == String(repeating: "2", count: 64))
        #expect(record.settlement.kind == .maturation)
    }

    @Test("Creates AnyHedge contract settlement record from contract plan")
    func createAnyHedgeContractSettlementRecordFromContractPlan() throws {
        let clientContext = OpalHedge.Client.Context()
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let previousOracleProof = try OpalHedgeContractFixtureBuilder
            .makeStartingSettlementOracleProof()
        let settlementOracleProof = try OpalHedgeContractFixtureBuilder
            .makeSettlementOracleProof()
        let record = try clientContext.createAnyHedgeContractSettlementRecord(
            from: plan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof,
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let settlementRequest = try clientContext
            .createAnyHedgeContractSettlementRequest(
                from: plan,
                fundingTransactionHash: String(repeating: "1", count: 64),
                fundingOutputIndex: 0,
                previousOracleProof: previousOracleProof,
                settlementOracleProof: settlementOracleProof
            )
        let expectedRecord = try settlementRequest.createSettlementRecord(
            settlementTransactionHash: String(repeating: "2", count: 64)
        )

        #expect(record == expectedRecord)
        #expect(record.draftData.parameters == plan.parameters)
        #expect(record.settlement.kind == .maturation)
    }

    @Test("Passes AnyHedge contract settlement record options through client context")
    func passAnyHedgeContractSettlementRecordOptionsThroughClientContext() throws {
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
            address: OpalHedgeFixtureData.longPayoutAddress,
            satoshis: 1_000
        )
        let record = try OpalHedge.Client.Context()
            .createAnyHedgeContractSettlementRecord(
                from: OpalHedgeFixtureData.contractCreationContext,
                fundingTransactionHash: String(repeating: "1", count: 64),
                fundingOutputIndex: 1,
                previousOracleProof: previousOracleProof,
                settlementOracleProof: settlementOracleProof,
                settlementTransactionHash: String(repeating: "2", count: 64),
                network: .regtest,
                fundings: [existingFunding],
                fees: [feeData]
            )

        #expect(record.settlement.kind == .liquidation)
        #expect(record.draftData.fundings.first == existingFunding)
        #expect(record.draftData.fundings.last == record.funding)
        #expect(record.draftData.fees == [feeData])
    }

    @Test("Creates AnyHedge contract settlement record from data document")
    func createAnyHedgeContractSettlementRecordFromDataDocument() throws {
        let clientContext = OpalHedge.Client.Context()
        let expectedRecord = try clientContext.createAnyHedgeContractSettlementRecord(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof(
                    messageTimestamp: 6_663_643,
                    priceValue: 23_500
                ),
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: expectedRecord.dataDocument.jsonText
        )
        let record = try clientContext.createAnyHedgeContractSettlementRecord(
            from: decodedDocument
        )

        #expect(record == expectedRecord)
    }
}
