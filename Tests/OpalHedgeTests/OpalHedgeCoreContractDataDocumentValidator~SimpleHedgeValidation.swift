// OpalHedgeCoreContractDataDocumentValidator~SimpleHedgeValidation.swift

import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentValidator {
    @Test(
        "Rejects metadata whose simple hedge flag disagrees with the contract",
        arguments: [(Int64(0), Int64(1)), (Int64(1), Int64(0))]
    )
    func rejectInconsistentSimpleHedgeMetadata(
        expectedFlag: Int64,
        actualFlag: Int64
    ) throws {
        let validDraftData = try makeSimpleHedgeDraftData(isSimpleHedge: expectedFlag)
        let inconsistentDraftData = OpalHedge.Core.ContractDraftData(
            parameters: validDraftData.parameters,
            metadata: makeMetadata(
                from: validDraftData.metadata,
                isSimpleHedge: actualFlag
            ),
            fundings: validDraftData.fundings,
            fees: validDraftData.fees
        )

        let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: inconsistentDraftData)
        }
        #expect(error == .inconsistentMetadataComponent(
            name: "isSimpleHedge",
            expected: expectedFlag,
            actual: actualFlag
        ))
    }

    @Test(
        "Rejects nonboolean simple hedge metadata flags",
        arguments: [Int64(-1), Int64(2)]
    )
    func rejectNonbooleanSimpleHedgeMetadata(actualFlag: Int64) throws {
        let validDraftData = try makeSimpleHedgeDraftData(isSimpleHedge: 1)
        let invalidDraftData = OpalHedge.Core.ContractDraftData(
            parameters: validDraftData.parameters,
            metadata: makeMetadata(
                from: validDraftData.metadata,
                isSimpleHedge: actualFlag
            ),
            fundings: validDraftData.fundings,
            fees: validDraftData.fees
        )

        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: invalidDraftData)
        }
        #expect(error == .invalidBooleanInteger(name: "isSimpleHedge", value: actualFlag))
    }

    @Test(
        "Round trips simple and nonsimple contract metadata without changing its flag",
        arguments: [Int64(0), Int64(1)]
    )
    func roundTripMatchingSimpleHedgeMetadata(isSimpleHedge: Int64) throws {
        let draftData = try makeSimpleHedgeDraftData(isSimpleHedge: isSimpleHedge)
        let document = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        let decodedDocument = try OpalHedge.Core.ContractDataDocument(utf8Data: document.utf8Data)

        #expect(decodedDocument.draftData.metadata.isSimpleHedge == isSimpleHedge)
        #expect(decodedDocument.draftData == draftData)
        #expect(decodedDocument.jsonText == document.jsonText)
    }

    private func makeSimpleHedgeDraftData(
        isSimpleHedge: Int64
    ) throws -> OpalHedge.Core.ContractDraftData {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeContractFixtureBuilder.makeCreationContext(
                isSimpleHedge: isSimpleHedge
            )
        )
        return OpalHedge.Core.ContractDraftData(plan: plan)
    }
}
