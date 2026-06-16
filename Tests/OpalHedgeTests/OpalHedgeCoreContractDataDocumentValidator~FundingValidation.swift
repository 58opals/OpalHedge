// OpalHedgeCoreContractDataDocumentValidator~FundingValidation.swift

import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentValidator {
    @Test("Rejects invalid funding transaction hash when creating contract data document")
    func rejectInvalidFundingTransactionHashWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: "zz",
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049
                )
            ]
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        }

        #expect(
            error == .invalidTransactionHashHex(
                name: "fundings[0].fundingTransactionHash",
                value: "zz"
            )
        )
    }

    @Test("Rejects nonpositive funding satoshis when creating contract data document")
    func rejectNonpositiveFundingSatoshisWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 0
                )
            ]
        )
        let error = try #require(OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        })

        #expect(
            error == .invalidPositiveInteger(
                name: "fundings[0].fundingSatoshis",
                value: 0
            )
        )
    }

    @Test("Rejects negative funding output index when creating contract data document")
    func rejectNegativeFundingOutputIndexWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: -1,
                    fundingSatoshis: 5_651_049
                )
            ]
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        }

        #expect(
            error == .invalidNonnegativeInteger(
                name: "fundings[0].fundingOutputIndex",
                value: -1
            )
        )
    }
}
