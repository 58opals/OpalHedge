// OpalHedgeCoreDiagnosticErrorCode.swift

enum OpalHedgeCoreDiagnosticErrorCode {
    static let unknown = "unknown"
    static let contractConstraintValidationFailed = "contract.constraint_validation_failed"
    static let dataDocumentInvalidJson = "data_document.invalid_json"
    static let dataDocumentInvalidRootObject = "data_document.invalid_root_object"
    static let dataDocumentMissingField = "data_document.missing_field"
    static let dataDocumentInvalidFieldType = "data_document.invalid_field_type"
    static let dataDocumentInvalidContractSide = "data_document.invalid_contract_side"
    static let dataDocumentInvalidSettlementType = "data_document.invalid_settlement_type"
    static let settlementConditionInvalid = "settlement.condition_invalid"
    static let settlementPayoutInvalid = "settlement.payout_invalid"
}
