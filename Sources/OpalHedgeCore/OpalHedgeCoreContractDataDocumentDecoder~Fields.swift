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
        guard let array = value as? [Any] else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "array"
            )
        }

        return try array.map { element in
            guard let child = element as? [String: Any] else {
                throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                    name: name,
                    expected: "object"
                )
            }

            return child
        }
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
        guard let number = value as? NSNumber,
              isIntegerNumber(number) else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "integer"
            )
        }

        guard let int64 = Int64(number.stringValue) else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "integer"
            )
        }

        return int64
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
        guard let number = value as? NSNumber,
              !isBooleanNumber(number) else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "number"
            )
        }

        let double = number.doubleValue
        guard double.isFinite else {
            throw OpalHedgeCoreContractDataDocumentError.invalidFieldType(
                name: name,
                expected: "finite number"
            )
        }

        return double
    }

    private static func isIntegerNumber(_ number: NSNumber) -> Bool {
        guard !isBooleanNumber(number) else {
            return false
        }

        switch CFNumberGetType(number) {
        case .sInt8Type,
            .sInt16Type,
            .sInt32Type,
            .sInt64Type,
            .charType,
            .shortType,
            .intType,
            .longType,
            .longLongType,
            .cfIndexType,
            .nsIntegerType:
            return true
        default:
            return false
        }
    }

    private static func isBooleanNumber(_ number: NSNumber) -> Bool {
        CFGetTypeID(number) == CFBooleanGetTypeID()
    }
}
