// OpalHedgeContractDataDocumentMutationTool~Removal.swift

import Foundation
import Testing

extension OpalHedgeContractDataDocumentMutationTool {
    static func makeJsonText(
        removingFieldAt fieldPath: OpalHedgeContractDataDocumentFieldPathData,
        from jsonText: String
    ) throws -> String {
        switch fieldPath {
        case .topLevel(let fieldName):
            return try Self.makeJsonText(
                removingTopLevelField: fieldName,
                from: jsonText
            )
        case .parameter(let fieldName):
            return try Self.makeJsonText(
                removingField: fieldName,
                inTopLevelObject: "parameters",
                from: jsonText
            )
        case .metadata(let fieldName):
            return try Self.makeJsonText(
                removingField: fieldName,
                inTopLevelObject: "metadata",
                from: jsonText
            )
        case .firstFunding(let fieldName):
            return try Self.makeJsonText(
                removingField: fieldName,
                inFirstElementOf: "fundings",
                from: jsonText
            )
        case .firstFee(let fieldName):
            return try Self.makeJsonText(
                removingField: fieldName,
                inFirstElementOf: "fees",
                from: jsonText
            )
        case .firstFundingSettlement(let fieldName):
            return try Self.makeJsonText(
                removingSettlementField: fieldName,
                from: jsonText
            )
        }
    }

    static func makeJsonText(
        removingTopLevelField name: String,
        from jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        dictionary.removeValue(forKey: name)

        return try Self.makeJsonText(from: dictionary)
    }

    static func makeJsonText(
        removingField fieldName: String,
        inTopLevelObject objectName: String,
        from jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        var object = try #require(dictionary[objectName] as? [String: Any])
        object.removeValue(forKey: fieldName)
        dictionary[objectName] = object

        return try Self.makeJsonText(from: dictionary)
    }

    static func makeJsonText(
        removingField fieldName: String,
        inFirstElementOf arrayName: String,
        from jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        var elements = try #require(dictionary[arrayName] as? [[String: Any]])
        var element = try #require(elements.first)
        element.removeValue(forKey: fieldName)
        elements[0] = element
        dictionary[arrayName] = elements

        return try Self.makeJsonText(from: dictionary)
    }

    static func makeJsonText(
        removingSettlementField fieldName: String,
        from jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        var fundings = try #require(dictionary["fundings"] as? [[String: Any]])
        var funding = try #require(fundings.first)
        var settlement = try #require(funding["settlement"] as? [String: Any])
        settlement.removeValue(forKey: fieldName)
        funding["settlement"] = settlement
        fundings[0] = funding
        dictionary["fundings"] = fundings

        return try Self.makeJsonText(from: dictionary)
    }
}
