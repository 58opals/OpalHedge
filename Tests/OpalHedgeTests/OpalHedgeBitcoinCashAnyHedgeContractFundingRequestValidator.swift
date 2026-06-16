// OpalHedgeBitcoinCashAnyHedgeContractFundingRequestValidator.swift

import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractFundingRequestValidator {
    @Test("Creates AnyHedge contract funding request from bundle")
    func createAnyHedgeContractFundingRequestFromBundle() throws {
        let bundle = try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )
        let request = bundle.fundingRequest

        #expect(request.fundingOutput == bundle.fundingOutput)
        #expect(request.domainDataDocument == bundle.dataDocument)
        #expect(request.rawRedeemScriptBytecode == bundle.bytecode.rawRedeemScriptBytecode)
        #expect(request.contractScriptArtifact == .anyHedgeV0_12)
        #expect(request.fundingOutput.satoshis == 5_651_049)
        #expect(request.rawRedeemScriptBytecode.count == 343)
        #expect(request.reviewSummary.fundingSatoshis == 5_651_049)
        #expect(request.reviewSummary.domainDataDocumentByteCount == bundle.dataDocument.utf8Data.count)
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
        #expect(request.domainDataDocument.jsonText == OpalHedgeFixtureData
            .upstreamHedgeTenWeekContractDataDocumentJsonText)
    }

    @Test("Funding review summary excludes raw script and domain document storage")
    func fundingReviewSummaryExcludesRawScriptAndDomainDocumentStorage() throws {
        let summary = try OpalHedge.Client.Context()
            .createAnyHedgeContractFundingRequest(
                from: OpalHedgeFixtureData.contractCreationContext
            )
            .reviewSummary
        let labels = Set(Mirror(reflecting: summary).children.compactMap(\.label))

        #expect(labels.contains("contractAddressDisplayValue"))
        #expect(labels.contains("fundingSatoshis"))
        #expect(labels.contains("rawRedeemScriptBytecode") == false)
        #expect(labels.contains("domainDataDocument") == false)
        #expect(labels.contains("signatureHex") == false)
    }

    @Test("Creates AnyHedge contract funding request from contract plan with client context")
    func createAnyHedgeContractFundingRequestFromContractPlanWithClientContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let request = try clientContext.createAnyHedgeContractFundingRequest(
            from: plan
        )
        let bundle = try clientContext.createAnyHedgeContractBundle(
            from: plan
        )

        #expect(request == bundle.fundingRequest)
        #expect(request.domainDataDocument.draftData.parameters == plan.parameters)
        #expect(request.fundingOutput.contractAddress == bundle.contractAddress)
    }

    @Test("Reconstructs AnyHedge contract funding request from data document")
    func reconstructAnyHedgeContractFundingRequestFromDataDocument() throws {
        let bundle = try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: bundle.dataDocument.jsonText
        )
        let request = try OpalHedge.BitcoinCash.AnyHedgeContractFundingRequest(
            dataDocument: decodedDocument
        )

        #expect(request == bundle.fundingRequest)
        #expect(request.domainDataDocument == decodedDocument)
        #expect(request.fundingOutput.contractAddress.rawValue == "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx")
    }

    @Test("Rejects unverified starting oracle signature in data document")
    func rejectUnverifiedStartingOracleSignatureInDataDocument() throws {
        let bundle = try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )
        let tamperedSignatureHex = "0" + String(
            OpalHedgeFixtureData.startingOracleSignatureHex.dropFirst()
        )
        let tamperedJsonText = try OpalHedgeContractDataDocumentMutationTool
            .makeJsonText(
                replacingFieldAt: .metadata("startingOracleSignature"),
                with: tamperedSignatureHex,
                in: bundle.dataDocument.jsonText
            )
        let tamperedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: tamperedJsonText
        )

        var didRejectTamperedProof = false
        do {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractFundingRequest(
                dataDocument: tamperedDocument
            )
        } catch {
            didRejectTamperedProof = true
        }

        #expect(didRejectTamperedProof)
    }

    @Test("Creates AnyHedge contract funding request from data document with client context")
    func createAnyHedgeContractFundingRequestFromDataDocumentWithClientContext() throws {
        let clientContext = OpalHedge.Client.Context()
        let creationContext = OpalHedgeContractFixtureBuilder.makeCreationContext(
            shortPayoutAddress: OpalHedgeFixtureData.shortRegtestPayoutAddress,
            longPayoutAddress: OpalHedgeFixtureData.longRegtestPayoutAddress
        )
        let bundle = try clientContext.createAnyHedgeContractBundle(
            from: creationContext,
            network: .regtest
        )
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(
            jsonText: bundle.dataDocument.jsonText
        )
        let request = try clientContext.createAnyHedgeContractFundingRequest(
            from: decodedDocument,
            network: .regtest
        )

        #expect(request.domainDataDocument == decodedDocument)
        #expect(request.fundingOutput.contractAddress.rawValue == "bchreg:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsr6pyr2gu")
        #expect(request.rawRedeemScriptBytecode == bundle.fundingRequest.rawRedeemScriptBytecode)
    }

    @Test("Rejects funding request from funded data document")
    func rejectFundingRequestFromFundedDataDocument() throws {
        let bundle = try OpalHedgeBitcoinCashAnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )
        let fundingRecord = try bundle.createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let error = captureFundingRequestError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractFundingRequest(
                dataDocument: fundingRecord.dataDocument
            )
        }

        #expect(error == .contractAlreadyFunded(fundingCount: 1))
    }

    @Test("Rejects client funding request with existing fundings")
    func rejectClientFundingRequestWithExistingFundings() throws {
        let clientContext = OpalHedge.Client.Context()
        let existingFunding = OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            fundingSatoshis: 5_651_049
        )
        let error = captureFundingRequestError {
            _ = try clientContext.createAnyHedgeContractFundingRequest(
                from: OpalHedgeFixtureData.contractCreationContext,
                fundings: [existingFunding]
            )
        }

        #expect(error == .contractAlreadyFunded(fundingCount: 1))
    }

    private func captureFundingRequestError(
        _ operation: () throws -> Void
    ) -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRequestError? {
        do {
            try operation()
        } catch let error as OpalHedge.BitcoinCash.AnyHedgeContractFundingRequestError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }
}
