// OpalHedgeCoreContractDataDocumentValidator~FeeAndMetadataValidation.swift

import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentValidator {
    @Test("Rejects nonpositive fee satoshis when creating contract data document")
    func rejectNonpositiveFeeSatoshisWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData(
            fees: [
                OpalHedge.Core.ContractFeeData(
                    name: "settlement",
                    description: "Settlement service fee",
                    address: OpalHedgeFixtureData.longPayoutAddress,
                    satoshis: 0
                )
            ]
        )
        let error = try #require(OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        })

        #expect(error == .invalidPositiveInteger(name: "fees[0].satoshis", value: 0))
    }

    @Test("Rejects invalid fee address when creating contract data document")
    func rejectInvalidFeeAddressWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData(
            fees: [
                OpalHedge.Core.ContractFeeData(
                    name: "settlement",
                    description: "Settlement service fee",
                    address: "not-an-address",
                    satoshis: 1_000
                )
            ]
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        }

        #expect(
            error == .invalidPayoutAddress(
                name: "fees[0].address",
                value: "not-an-address"
            )
        )
    }

    @Test("Rejects negative miner cost when creating contract data document")
    func rejectNegativeMinerCostWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData()
        let invalidDraftData = OpalHedge.Core.ContractDraftData(
            parameters: draftData.parameters,
            metadata: makeMetadata(
                from: draftData.metadata,
                minerCostInSatoshis: -1
            ),
            fundings: draftData.fundings,
            fees: draftData.fees
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: invalidDraftData)
        }

        #expect(
            error == .invalidNonnegativeInteger(
                name: "minerCostInSatoshis",
                value: -1
            )
        )
    }

    @Test("Rejects matching taker and maker sides when creating contract data document")
    func rejectMatchingTakerAndMakerSidesWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData()
        let invalidDraftData = OpalHedge.Core.ContractDraftData(
            parameters: draftData.parameters,
            metadata: makeMetadata(
                from: draftData.metadata,
                takerSide: .short,
                makerSide: .short
            ),
            fundings: draftData.fundings,
            fees: draftData.fees
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: invalidDraftData)
        }

        #expect(error == .makerSideMustOpposeTaker(taker: .short, maker: .short))
    }
}
