// OpalHedgeContractDataDocumentJSONMutation.swift

import Foundation
import Testing

enum OpalHedgeContractDataDocumentJSONMutation {
    static func jsonText(
        replacingFieldAt fieldPath: OpalHedgeContractDataDocumentFieldPath,
        with fieldValue: Any,
        in jsonText: String
    ) throws -> String {
        switch fieldPath {
        case .topLevel(let fieldName):
            return try Self.jsonText(
                replacingTopLevelField: fieldName,
                with: fieldValue,
                in: jsonText
            )
        case .parameter(let fieldName):
            return try Self.jsonText(
                replacingField: fieldName,
                inTopLevelObject: "parameters",
                with: fieldValue,
                in: jsonText
            )
        case .metadata(let fieldName):
            return try Self.jsonText(
                replacingField: fieldName,
                inTopLevelObject: "metadata",
                with: fieldValue,
                in: jsonText
            )
        case .firstFunding(let fieldName):
            return try Self.jsonText(
                replacingField: fieldName,
                inFirstElementOf: "fundings",
                with: fieldValue,
                in: jsonText
            )
        case .firstFee(let fieldName):
            return try Self.jsonText(
                replacingField: fieldName,
                inFirstElementOf: "fees",
                with: fieldValue,
                in: jsonText
            )
        case .firstFundingSettlement(let fieldName):
            return try Self.jsonText(
                replacingSettlementField: fieldName,
                with: fieldValue,
                in: jsonText
            )
        }
    }

    static func jsonText(
        replacingFieldAt fieldPath: OpalHedgeContractDataDocumentFieldPath,
        withRawJSONValue rawJSONValue: String,
        in jsonText: String
    ) throws -> String {
        let marker = "__OPAL_HEDGE_RAW_JSON_VALUE__"
        let markerJsonText = try Self.jsonText(
            replacingFieldAt: fieldPath,
            with: marker,
            in: jsonText
        )

        return markerJsonText.replacingOccurrences(
            of: "\"\(marker)\"",
            with: rawJSONValue
        )
    }

    static func jsonText(
        replacingTopLevelField name: String,
        with value: Any,
        in jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        dictionary[name] = value

        return try Self.jsonText(from: dictionary)
    }

    static func jsonText(
        replacingField fieldName: String,
        inTopLevelObject objectName: String,
        with fieldValue: Any,
        in jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        var object = try #require(dictionary[objectName] as? [String: Any])
        object[fieldName] = fieldValue
        dictionary[objectName] = object

        return try Self.jsonText(from: dictionary)
    }

    static func jsonText(
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

        return try Self.jsonText(from: dictionary)
    }

    static func jsonText(
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

        return try Self.jsonText(from: dictionary)
    }

    static func jsonText(
        removingFieldAt fieldPath: OpalHedgeContractDataDocumentFieldPath,
        from jsonText: String
    ) throws -> String {
        switch fieldPath {
        case .topLevel(let fieldName):
            return try Self.jsonText(
                removingTopLevelField: fieldName,
                from: jsonText
            )
        case .parameter(let fieldName):
            return try Self.jsonText(
                removingField: fieldName,
                inTopLevelObject: "parameters",
                from: jsonText
            )
        case .metadata(let fieldName):
            return try Self.jsonText(
                removingField: fieldName,
                inTopLevelObject: "metadata",
                from: jsonText
            )
        case .firstFunding(let fieldName):
            return try Self.jsonText(
                removingField: fieldName,
                inFirstElementOf: "fundings",
                from: jsonText
            )
        case .firstFee(let fieldName):
            return try Self.jsonText(
                removingField: fieldName,
                inFirstElementOf: "fees",
                from: jsonText
            )
        case .firstFundingSettlement(let fieldName):
            return try Self.jsonText(
                removingSettlementField: fieldName,
                from: jsonText
            )
        }
    }

    static func jsonText(
        removingTopLevelField name: String,
        from jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        dictionary.removeValue(forKey: name)

        return try Self.jsonText(from: dictionary)
    }

    static func jsonText(
        removingField fieldName: String,
        inTopLevelObject objectName: String,
        from jsonText: String
    ) throws -> String {
        var dictionary = try topLevelDictionary(from: jsonText)
        var object = try #require(dictionary[objectName] as? [String: Any])
        object.removeValue(forKey: fieldName)
        dictionary[objectName] = object

        return try Self.jsonText(from: dictionary)
    }

    static func jsonText(
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

        return try Self.jsonText(from: dictionary)
    }

    static func jsonText(
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

        return try Self.jsonText(from: dictionary)
    }

    private static func topLevelDictionary(from jsonText: String) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(
            with: Data(jsonText.utf8)
        ) as? [String: Any])
    }

    private static func jsonText(from dictionary: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(
            withJSONObject: dictionary,
            options: [.sortedKeys]
        )

        return String(decoding: data, as: UTF8.self)
    }
}
