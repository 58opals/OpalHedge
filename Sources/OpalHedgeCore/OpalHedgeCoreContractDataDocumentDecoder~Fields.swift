// OpalHedgeCoreContractDataDocumentDecoder~Fields.swift

import Foundation

extension OpalHedgeCoreContractDataDocumentDecoder {
    static func side(
        _ name: String,
        in dictionary: [String: Any]
    ) throws -> OpalHedgeCoreContractSide {
        let value = try string(name, in: dictionary)
        switch value {
        case "Hedge":
            return .short
        case "Long":
            return .long
        default:
            throw OpalHedgeCoreContractDataDocumentError.invalidContractSide(value)
        }
    }

    static func childDictionary(
        _ name: String,
        in dictionary: [String: Any]
    ) throws -> [String: Any] {
        guard let value = dictionary[name] else {
            throw OpalHedgeCoreContractDataDocumentError.missingField(name)
        }
        guard let child = value as? [String: Any] else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "object"
            )
        }

        return child
    }

    static func optionalChildDictionary(
        _ name: String,
        in dictionary: [String: Any]
    ) throws -> [String: Any]? {
        guard let value = dictionary[name] else {
            return nil
        }
        guard let child = value as? [String: Any] else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "object"
            )
        }

        return child
    }

    static func childDictionaryArray(
        _ name: String,
        in dictionary: [String: Any]
    ) throws -> [[String: Any]] {
        guard let value = dictionary[name] else {
            throw OpalHedgeCoreContractDataDocumentError.missingField(name)
        }
        guard let array = value as? [[String: Any]] else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "array"
            )
        }

        return array
    }

    static func string(_ name: String, in dictionary: [String: Any]) throws -> String {
        guard let value = dictionary[name] else {
            throw OpalHedgeCoreContractDataDocumentError.missingField(name)
        }
        guard let text = value as? String else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "string"
            )
        }

        return text
    }

    static func optionalString(
        _ name: String,
        in dictionary: [String: Any]
    ) throws -> String? {
        guard dictionary[name] != nil else {
            return nil
        }

        return try string(name, in: dictionary)
    }

    static func int64(_ name: String, in dictionary: [String: Any]) throws -> Int64 {
        guard let value = dictionary[name] else {
            throw OpalHedgeCoreContractDataDocumentError.missingField(name)
        }
        guard let number = value as? NSNumber else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "integer"
            )
        }

        return number.int64Value
    }

    static func optionalInt64(
        _ name: String,
        in dictionary: [String: Any]
    ) throws -> Int64? {
        guard dictionary[name] != nil else {
            return nil
        }

        return try int64(name, in: dictionary)
    }

    static func double(_ name: String, in dictionary: [String: Any]) throws -> Double {
        guard let value = dictionary[name] else {
            throw OpalHedgeCoreContractDataDocumentError.missingField(name)
        }
        guard let number = value as? NSNumber else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "number"
            )
        }

        return number.doubleValue
    }
}
