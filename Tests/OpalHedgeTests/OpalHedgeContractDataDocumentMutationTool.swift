// OpalHedgeContractDataDocumentMutationTool.swift

import Foundation
import Testing

enum OpalHedgeContractDataDocumentMutationTool {
    static func makeJsonText(
        replacingFieldAt fieldPath: OpalHedgeContractDataDocumentFieldPathData,
        with fieldValue: Any,
        in jsonText: String
    ) throws -> String {
        switch fieldPath {
        case .topLevel(let fieldName):
            return try Self.makeJsonText(
                replacingTopLevelField: fieldName,
                with: fieldValue,
                in: jsonText
            )
        case .parameter(let fieldName):
            return try Self.makeJsonText(
                replacingField: fieldName,
                inTopLevelObject: "parameters",
                with: fieldValue,
                in: jsonText
            )
        case .metadata(let fieldName):
            return try Self.makeJsonText(
                replacingField: fieldName,
                inTopLevelObject: "metadata",
                with: fieldValue,
                in: jsonText
            )
        case .firstFunding(let fieldName):
            return try Self.makeJsonText(
                replacingField: fieldName,
                inFirstElementOf: "fundings",
                with: fieldValue,
                in: jsonText
            )
        case .firstFee(let fieldName):
            return try Self.makeJsonText(
                replacingField: fieldName,
                inFirstElementOf: "fees",
                with: fieldValue,
                in: jsonText
            )
        case .firstFundingSettlement(let fieldName):
            return try Self.makeJsonText(
                replacingSettlementField: fieldName,
                with: fieldValue,
                in: jsonText
            )
        }
    }

    static func makeJsonText(
        replacingFieldAt fieldPath: OpalHedgeContractDataDocumentFieldPathData,
        withRawJSONValue rawJSONValue: String,
        in jsonText: String
    ) throws -> String {
        let marker = "__OPAL_HEDGE_RAW_JSON_VALUE__"
        let markerJsonText = try Self.makeJsonText(
            replacingFieldAt: fieldPath,
            with: marker,
            in: jsonText
        )

        return markerJsonText.replacingOccurrences(
            of: "\"\(marker)\"",
            with: rawJSONValue
        )
    }

    static func makeJsonText(
        replacingTopLevelField name: String,
        with value: Any,
        in jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        dictionary[name] = value

        return try Self.makeJsonText(from: dictionary)
    }

    static func makeJsonText(
        replacingField fieldName: String,
        inTopLevelObject objectName: String,
        with fieldValue: Any,
        in jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        var object = try #require(dictionary[objectName] as? [String: Any])
        object[fieldName] = fieldValue
        dictionary[objectName] = object

        return try Self.makeJsonText(from: dictionary)
    }

    static func makeJsonText(
        replacingField fieldName: String,
        inFirstElementOf arrayName: String,
        with fieldValue: Any,
        in jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        var elements = try #require(dictionary[arrayName] as? [[String: Any]])
        var element = try #require(elements.first)
        element[fieldName] = fieldValue
        elements[0] = element
        dictionary[arrayName] = elements

        return try Self.makeJsonText(from: dictionary)
    }

    static func makeJsonText(
        replacingSettlementField fieldName: String,
        with fieldValue: Any,
        in jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        var fundings = try #require(dictionary["fundings"] as? [[String: Any]])
        var funding = try #require(fundings.first)
        var settlement = try #require(funding["settlement"] as? [String: Any])
        settlement[fieldName] = fieldValue
        funding["settlement"] = settlement
        fundings[0] = funding
        dictionary["fundings"] = fundings

            return try Self.makeJsonText(from: dictionary)
    }
    static func topLevelDictionary(from jsonText: String) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(
            with: Data(jsonText.utf8)
        ) as? [String: Any])
    }

    static func makeJsonText(from dictionary: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(
            withJSONObject: dictionary,
            options: [.sortedKeys]
        )

        return String(decoding: data, as: UTF8.self)
    }
}
