// OpalHedgeFacadeValidator.swift

import Testing
import OpalHedge

struct OpalHedgeFacadeValidator {
    @Test("Creates facade contexts")
    func createFacadeContexts() {
        _ = OpalHedge.Core.Context()
        _ = OpalHedge.Oracle.Context()
        _ = OpalHedge.Client.Context()
    }

    @Test("Uses Core facade aliases")
    func useCoreFacadeAliases() throws {
        let message = try OpalHedge.Oracle.PriceMessage.parse(
            rawHex: OpalHedgeFixtureData.startingOracleMessageHex
        )
        let outcome = try OpalHedge.Core.SettlementCalculator.calculateOutcome(
            parameters: OpalHedgeFixtureData.contractParameters,
            fundingSatoshis: 5_651_049,
            redeemPrice: message.priceValue
        )

        #expect(outcome.shortPayoutSatsSafe == 4_237_288)
    }

    @Test("Uses Core settlement facade aliases")
    func useCoreSettlementFacadeAliases() throws {
        let payoutAmounts = OpalHedge.Core.ContractSettlementPayoutAmounts(
            shortPayoutInSatoshis: 4_255_319,
            longPayoutInSatoshis: 1_394_398
        )
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: OpalHedge.Core.SettlementKind.maturation,
            settlementTransactionHash: String(repeating: "2", count: 64),
            payoutAmounts: payoutAmounts,
            settlementMessageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            settlementSignatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            previousMessageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            previousSignatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            settlementPrice: 23_500
        )
        let funding = OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            fundingSatoshis: 5_651_049,
            settlement: settlement
        )
        let draftData = OpalHedge.Core.ContractDraftData(
            plan: try OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            ),
            fundings: [funding]
        )
        let document = try OpalHedge.Core.ContractDataDocument(draftData: draftData)

        #expect(document.jsonText.contains("\"settlement\""))
        #expect(settlement.totalPayoutInSatoshis == 5_649_717)
    }

    @Test("Uses Bitcoin Cash settlement facade aliases")
    func useBitcoinCashSettlementFacadeAliases() throws {
        let clientContext = OpalHedge.Client.Context()
        let contractPlan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let settlementRequest = try clientContext.createAnyHedgeContractSettlementRequest(
            from: contractPlan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof()
        )
        let settlementRecord = try clientContext.createAnyHedgeContractSettlementRecord(
            from: contractPlan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof(),
            settlementTransactionHash: String(repeating: "2", count: 64)
        )
        let summary = try clientContext.createAnyHedgeContractSettlementSummary(
            from: contractPlan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeSettlementOracleProof(),
            settlementTransactionHash: String(repeating: "2", count: 64)
        )

        #expect(summary.settlementPayoutAmounts ==
            OpalHedge.BitcoinCash.AnyHedgeContractSettlementPayoutAmounts(
                settlementOutcome: settlementRequest.settlementOutcome
            ))
        #expect(settlementRecord.lifecycleState == .settled(settlementRecord))
    }

    @Test("Uses Bitcoin Cash data document reconstruction facade aliases")
    func useBitcoinCashDataDocumentReconstructionFacadeAliases() throws {
        let clientContext = OpalHedge.Client.Context()
        let contractPlan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeContractFixtureBuilder.makeVerifiedCreationContext()
        )
        let fundingRequest = try clientContext.createAnyHedgeContractFundingRequest(
            from: contractPlan
        )
        let fundingRecord = try clientContext.createAnyHedgeContractFundingRecord(
            from: contractPlan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let settlementRecord = try clientContext.createAnyHedgeContractSettlementRecord(
            from: contractPlan,
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            previousOracleProof: OpalHedgeContractFixtureBuilder
                .makeVerifiedStartingSettlementOracleProof(),
            settlementOracleProof: OpalHedgeContractFixtureBuilder
                .makeVerifiedSettlementOracleProof(),
            settlementTransactionHash: String(repeating: "2", count: 64)
        )

        let fundingRequestDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: fundingRequest.domainDataDocument.jsonText
        )
        let fundingRecordDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: fundingRecord.dataDocument.jsonText
        )
        let settlementRecordDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: settlementRecord.dataDocument.jsonText
        )

        let reconstructedFundingRequest = try OpalHedge.BitcoinCash
            .AnyHedgeContractFundingRequest(dataDocument: fundingRequestDocument)
        let reconstructedFundingRecord = try OpalHedge.BitcoinCash
            .AnyHedgeContractFundingRecord(dataDocument: fundingRecordDocument)
        let reconstructedSettlementRecord = try OpalHedge.BitcoinCash
            .AnyHedgeContractSettlementRecord(dataDocument: settlementRecordDocument)
        let reconstructedLifecycleState = try OpalHedge.BitcoinCash
            .AnyHedgeContractLifecycleState(dataDocument: settlementRecordDocument)
        let reconstructedSummary = try OpalHedge.BitcoinCash
            .AnyHedgeContractSettlementSummary(dataDocument: settlementRecordDocument)

        #expect(reconstructedFundingRequest == fundingRequest)
        #expect(reconstructedFundingRecord == fundingRecord)
        #expect(reconstructedSettlementRecord == settlementRecord)
        #expect(reconstructedLifecycleState == .settled(settlementRecord))
        #expect(reconstructedSummary == settlementRecord.settlementSummary)
    }

    @Test("Uses Oracle facade aliases")
    func useOracleFacadeAliases() throws {
        let message = try OpalHedge.Oracle.PriceMessage.parse(
            rawHex: OpalHedgeFixtureData.startingOracleMessageHex
        )
        let isSignatureValid = try OpalHedge.Oracle.SignatureVerifier.verify(
            message: message,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )

        #expect(isSignatureValid)
    }
}
