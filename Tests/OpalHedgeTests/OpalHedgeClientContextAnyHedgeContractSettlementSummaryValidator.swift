// OpalHedgeClientContextAnyHedgeContractSettlementSummaryValidator.swift

import Testing
import OpalHedge

struct OpalHedgeClientContextAnyHedgeContractSettlementSummaryValidator {
    @Test("Creates AnyHedge contract settlement summary from client context")
    func createAnyHedgeContractSettlementSummaryFromClientContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let previousOracleProof = try OpalHedgeContractFixtureBuilder
            .makeStartingSettlementOracleProof()
        let settlementOracleProof = try OpalHedgeContractFixtureBuilder
            .makeSettlementOracleProof()
        let summary = try clientContext.createAnyHedgeContractSettlementSummary(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof,
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let record = try clientContext.createAnyHedgeContractSettlementRecord(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof,
            settlementTransactionHash: String(repeating: "2", count: 64)
        )

        #expect(summary == record.settlementSummary)
        #expect(summary.settlementKind == .maturation)
        #expect(summary.settlementPrice == 23_500)
        #expect(summary.settlementTransactionHash == String(repeating: "2", count: 64))
    }

    @Test("Passes AnyHedge contract settlement summary options through client context")
    func passAnyHedgeContractSettlementSummaryOptionsThroughClientContext() throws {
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
        let summary = try OpalHedge.Client.Context()
            .createAnyHedgeContractSettlementSummary(
                from: OpalHedgeFixtureData.contractCreationContext,
                fundingTransactionHash: String(repeating: "1", count: 64),
                fundingOutputIndex: 1,
                previousOracleProof: OpalHedgeContractFixtureBuilder
                    .makeStartingSettlementOracleProof(),
                settlementOracleProof: OpalHedgeContractFixtureBuilder
                    .makeSettlementOracleProof(
                        messageTimestamp: 615_644,
                        priceValue: 17_500
                    ),
                settlementTransactionHash: String(repeating: "2", count: 64),
                network: .regtest,
                fundings: [existingFunding],
                fees: [feeData]
            )

        #expect(summary.settlementKind == .liquidation)
        #expect(summary.settlementPrice == 17_500)
        #expect(summary.fundingOutputIndex == 1)
        #expect(summary.dataDocument.jsonText.contains("\"satoshis\":1000"))
    }

    @Test("Creates AnyHedge contract settlement summary from data document")
    func createAnyHedgeContractSettlementSummaryFromDataDocument() throws {
        let clientContext = OpalHedge.Client.Context()
        let record = try clientContext.createAnyHedgeContractSettlementRecord(
            from: OpalHedgeFixtureData.contractCreationContext,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof(),
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: record.dataDocument.jsonText
        )
        let summary = try clientContext.createAnyHedgeContractSettlementSummary(
            from: decodedDocument
        )

        #expect(summary == record.settlementSummary)
    }
}
