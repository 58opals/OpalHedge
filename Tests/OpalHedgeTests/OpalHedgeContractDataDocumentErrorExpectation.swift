// OpalHedgeContractDataDocumentErrorExpectation.swift

import Testing
import OpalHedge

enum OpalHedgeContractDataDocumentErrorExpectation {
    typealias ContractDataDocumentError =
        OpalHedge.Core.ContractDataDocumentError

    static func expectMissingField(
        _ error: ContractDataDocumentError?,
        at fieldPath: OpalHedgeContractDataDocumentFieldPath
    ) {
        #expect(
            error == .missingField(fieldPath.fieldName),
            "Expected missing field at \(fieldPath.pathText)"
        )
        #expect(
            fieldName(from: error) == fieldPath.fieldName,
            "Expected missing field identity at \(fieldPath.pathText)"
        )
    }

    static func expectInvalidFieldType(
        _ error: ContractDataDocumentError?,
        at fieldPath: OpalHedgeContractDataDocumentFieldPath,
        expectedFieldType: String
    ) {
        #expect(
            error == .invalidFieldType(
                name: fieldPath.fieldName,
                expected: expectedFieldType
            ),
            "Expected invalid field type at \(fieldPath.pathText)"
        )
        #expect(
            fieldName(from: error) == fieldPath.fieldName,
            "Expected invalid field identity at \(fieldPath.pathText)"
        )
    }

    private static func fieldName(
        from error: ContractDataDocumentError?
    ) -> String? {
        switch error {
        case .some(.missingField(let fieldName)):
            return fieldName
        case .some(.invalidFieldType(let fieldName, _)):
            return fieldName
        default:
            return nil
        }
    }
}
