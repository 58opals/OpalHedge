// OpalHedgeCoreContractDataDocumentError.swift

public enum OpalHedgeCoreContractDataDocumentError: Error, Sendable, Equatable {
    case invalidJson
    case invalidRootObject
    case missingField(String)
    case invalidFieldType(name: String, expected: String)
    case invalidContractSide(String)
    case invalidSettlementType(String)
}
