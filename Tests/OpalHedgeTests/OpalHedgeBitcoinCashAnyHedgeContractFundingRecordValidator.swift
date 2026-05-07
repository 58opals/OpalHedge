// OpalHedgeBitcoinCashAnyHedgeContractFundingRecordValidator.swift

import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractFundingRecordValidator {
    @Test("Creates AnyHedge contract funding record")
    func createAnyHedgeContractFundingRecord() throws {
        let bundle = try makeBundle()
        let record = try bundle.createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let expectedFunding = OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0,
            fundingSatoshis: 5_651_049
        )

        #expect(record.funding == expectedFunding)
        #expect(record.fundingOutput == bundle.fundingOutput)
        #expect(record.draftData.fundings == [expectedFunding])
        #expect(record.draftData.fees == bundle.draftData.fees)
        #expect(record.dataDocument.jsonText.contains("\"fundingSatoshis\":5651049"))
        #expect(record.dataDocument.jsonText.contains("\"fundingOutputIndex\":0"))
    }

    @Test("Appends AnyHedge contract funding record to existing fundings")
    func appendAnyHedgeContractFundingRecordToExistingFundings() throws {
        let existingFunding = OpalHedge.Core.ContractFunding(
            fundingTransactionHash: String(repeating: "0", count: 64),
            fundingOutputIndex: 0,
            fundingSatoshis: 5_651_049
        )
        let bundle = try makeBundle(fundings: [existingFunding])
        let record = try bundle.createFundingRecord(
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 1,
            fundingSatoshis: 5_651_049
        )

        #expect(record.draftData.fundings.first == existingFunding)
        #expect(record.draftData.fundings.last == record.funding)
        #expect(record.draftData.fundings.count == 2)
    }

    @Test("Rejects invalid AnyHedge contract funding record")
    func rejectInvalidAnyHedgeContractFundingRecord() throws {
        let bundle = try makeBundle()
        let hashError = captureFundingRecordError {
            _ = try bundle.createFundingRecord(
                fundingTransactionHash: "zz",
                fundingOutputIndex: 0
            )
        }
        let satoshisError = captureFundingRecordError {
            _ = try bundle.createFundingRecord(
                fundingTransactionHash: String(repeating: "1", count: 64),
                fundingOutputIndex: 0,
                fundingSatoshis: 5_651_048
            )
        }

        #expect(hashError == .invalidFundingTransactionHash("zz"))
        #expect(
            satoshisError == .inconsistentFundingSatoshis(
                expected: 5_651_049,
                actual: 5_651_048
            )
        )
    }

    private func makeBundle(
        fundings: [OpalHedge.Core.ContractFunding] = []
    ) throws -> OpalHedge.BitcoinCash.AnyHedgeContractBundle {
        try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            ),
            fundings: fundings
        )
    }

    private func captureFundingRecordError(
        _ operation: () throws -> Void
    ) -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecordError? {
        do {
            try operation()
        } catch let error as OpalHedge.BitcoinCash.AnyHedgeContractFundingRecordError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }
}
