// OpalHedgeContractDataDocumentFieldPathData.swift

enum OpalHedgeContractDataDocumentFieldPathData: Hashable {
    case topLevel(String)
    case parameter(String)
    case metadata(String)
    case firstFunding(String)
    case firstFee(String)
    case firstFundingSettlement(String)

    var fieldName: String {
        switch self {
        case .topLevel(let fieldName),
            .parameter(let fieldName),
            .metadata(let fieldName),
            .firstFunding(let fieldName),
            .firstFee(let fieldName),
            .firstFundingSettlement(let fieldName):
            return fieldName
        }
    }

    var pathText: String {
        switch self {
        case .topLevel(let fieldName):
            return fieldName
        case .parameter(let fieldName):
            return "parameters.\(fieldName)"
        case .metadata(let fieldName):
            return "metadata.\(fieldName)"
        case .firstFunding(let fieldName):
            return "fundings[0].\(fieldName)"
        case .firstFee(let fieldName):
            return "fees[0].\(fieldName)"
        case .firstFundingSettlement(let fieldName):
            return "fundings[0].settlement.\(fieldName)"
        }
    }
}
