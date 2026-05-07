// OpalHedgeWalletBetaIntegrationValidator.swift

import Testing
import OpalHedge

struct OpalHedgeWalletBetaIntegrationValidator {
    @Test("Creates stable Opal Wallet beta funding output")
    func createStableOpalWalletBetaFundingOutput() throws {
        let clientContext = OpalHedge.Client.Context()
        let contractPlan = try makeContractPlan()
        let fundingRequest = try clientContext.createAnyHedgeContractFundingRequest(
            from: contractPlan
        )

        #expect(fundingRequest.fundingOutput.contractAddress.rawValue ==
            "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx")
        #expect(fundingRequest.fundingOutput.satoshis == 5_651_049)
        #expect(fundingRequest.contractScriptArtifact == .anyHedgeV0_12)
        #expect(fundingRequest.contractDataDocument.draftData.parameters ==
            contractPlan.parameters)
    }

    @Test("Reconstructs Opal Wallet beta funding record from persisted document")
    func reconstructOpalWalletBetaFundingRecordFromPersistedDocument() throws {
        let clientContext = OpalHedge.Client.Context()
        let contractPlan = try makeContractPlan()
        let fundingRecord = try clientContext.createAnyHedgeContractFundingRecord(
            from: contractPlan,
            fundingTransactionHash: fundingTransactionHash,
            fundingOutputIndex: 0
        )
        let persistedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: fundingRecord.dataDocument.jsonText
        )
        let reconstructedRecord = try clientContext.createAnyHedgeContractFundingRecord(
            from: persistedDocument
        )

        #expect(reconstructedRecord == fundingRecord)
        #expect(reconstructedRecord.lifecycleState == .funded(fundingRecord))
        #expect(reconstructedRecord.fundingOutput.satoshis == 5_651_049)
    }

    @Test("Summarizes Opal Wallet beta settlement outcome from persisted document")
    func summarizeOpalWalletBetaSettlementOutcomeFromPersistedDocument() throws {
        let clientContext = OpalHedge.Client.Context()
        let contractPlan = try makeContractPlan()
        let settlementSummary = try clientContext.createAnyHedgeContractSettlementSummary(
            from: contractPlan,
            fundingTransactionHash: fundingTransactionHash,
            fundingOutputIndex: 0,
            previousOracleProof: try makePreviousOracleProof(),
            settlementOracleProof: try makeSettlementOracleProof(),
            settlementTransactionHash: settlementTransactionHash
        )
        let persistedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: settlementSummary.dataDocument.jsonText
        )
        let reconstructedSummary = try clientContext.createAnyHedgeContractSettlementSummary(
            from: persistedDocument
        )

        #expect(reconstructedSummary == settlementSummary)
        #expect(reconstructedSummary.settlementKind == .maturation)
        #expect(reconstructedSummary.settlementPrice == 23_500)
        #expect(reconstructedSummary.hedgePayoutInSatoshis == 4_255_319)
        #expect(reconstructedSummary.longPayoutInSatoshis == 1_394_398)
        #expect(reconstructedSummary.totalPayoutInSatoshis == 5_649_717)
    }

    private var fundingTransactionHash: String {
        String(repeating: "1", count: 64)
    }

    private var settlementTransactionHash: String {
        String(repeating: "2", count: 64)
    }

    private func makeContractPlan() throws -> OpalHedge.Core.ContractPlan {
        let startingProof = try OpalHedge.Oracle.verifyStartingPriceProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )
        let creationContext = try OpalHedge.Core.ContractCreationContext(
            takerSide: .short,
            makerSide: .long,
            startingOracleProof: startingProof,
            shortPayoutAddress: OpalHedgeFixtureData.shortPayoutAddress,
            longPayoutAddress: OpalHedgeFixtureData.longPayoutAddress,
            shortLockScriptHex: OpalHedgeFixtureData.shortLockScriptHex,
            longLockScriptHex: OpalHedgeFixtureData.longLockScriptHex,
            nominalUnits: 1_000,
            maturityTimestamp: 6_663_643,
            isSimpleHedge: 1,
            highLiquidationPriceMultiplier: 10,
            lowLiquidationPriceMultiplier: 0.75,
            enableMutualRedemption: 1,
            shortMutualRedeemPublicKeyHex: OpalHedgeFixtureData
                .shortMutualRedeemPublicKeyHex,
            longMutualRedeemPublicKeyHex: OpalHedgeFixtureData
                .longMutualRedeemPublicKeyHex,
            minerCostInSatoshis: 632
        )

        return try OpalHedge.Core.ContractPlan(
            from: creationContext
        )
    }

    private func makePreviousOracleProof() throws -> OpalHedge.Core.ContractSettlementOracleProof {
        try OpalHedge.Oracle.verifySettlementOracleProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )
    }

    private func makeSettlementOracleProof() throws -> OpalHedge.Core.ContractSettlementOracleProof {
        try OpalHedgeContractFixtureBuilder.makeSettlementOracleProof()
    }
}
