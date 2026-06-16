// OpalHedgeCoreContractDataDocumentValidator~MetadataNumberValidation.swift

import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentValidator {
    @Test("Rejects non-finite metadata numbers when creating contract data document")
    func rejectNonFiniteMetadataNumbersWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData()
        let nonFiniteValues = [
            Double.nan,
            Double.infinity,
            -Double.infinity
        ]

        for fieldPath in metadataNumberFieldPaths {
            for value in nonFiniteValues {
                let invalidDraftData = try makeDraftData(
                    replacingMetadataNumberAt: fieldPath,
                    with: value,
                    in: draftData
                )
                let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                    _ = try OpalHedge.Core.ContractDataDocument(
                        draftData: invalidDraftData
                    )
                }

                OpalHedgeContractDataDocumentErrorExpectationTool.expectInvalidFieldType(
                    error,
                    at: fieldPath,
                    expectedFieldType: "finite number"
                )
            }
        }
    }

    @Test("Rejects start price drift when creating contract data document")
    func rejectStartPriceDriftWhenCreatingContractDataDocument() throws {
        let draftData = try makeDraftData()
        let driftedMetadata = makeMetadata(
            from: draftData.metadata,
            startPrice: draftData.metadata.startPrice + 1
        )
        let invalidDraftData = OpalHedge.Core.ContractDraftData(
            parameters: draftData.parameters,
            metadata: driftedMetadata
        )

        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(
                draftData: invalidDraftData
            )
        }

        #expect(error == .inconsistentOracleMessageComponent(
            name: "startPrice",
            expected: draftData.metadata.startPrice,
            actual: draftData.metadata.startPrice + 1
        ))
    }
}
