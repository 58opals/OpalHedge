// OpalHedgeOracleDiagnostics.swift

import Foundation
import OpalDiagnostics

enum OpalHedgeOracleDiagnostics {
    enum Category {
        static let oracle = OpalDiagnostics.Category(rawValue: "hedge.oracle")
    }

    enum Event {
        static let oracleMessageParsed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.message.parsed")
        static let oracleMessageParseFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.message.parse_failed")
        static let oracleSignatureVerified = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.signature.verified")
        static let oracleSignatureVerificationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.signature.verification_failed")
    }

    enum Field {
        static let operation = "operation"
        static let module = "module"
        static let errorCategory = "error_category"
        static let errorCode = "error_code"
        static let errorMessage = "error_message"
        static let byteCount = "byte_count"
        static let payloadType = "payload_type"
        static let messageTimestamp = "message_timestamp"
        static let messageSequence = "message_sequence"
        static let priceSequence = "price_sequence"
        static let priceValue = "price_value"
    }

    enum ErrorCode {
        static let unknown = "unknown"
        static let oracleInvalidHexLength = "oracle.invalid_hex_length"
        static let oracleInvalidHexCharacter = "oracle.invalid_hex_character"
        static let oracleInvalidMessageLength = "oracle.invalid_message_length"
        static let oracleInvalidScriptInteger = "oracle.invalid_script_integer"
        static let oracleInvalidPrice = "oracle.invalid_price"
        static let oracleInvalidPublicKey = "oracle.invalid_public_key"
        static let oracleInvalidSignature = "oracle.invalid_signature"
        static let oracleInvalidDigest = "oracle.invalid_digest"
        static let oracleCryptographyFailure = "oracle.cryptography_failure"
    }

    static func record(
        _ event: OpalDiagnostics.Event,
        level: OpalDiagnostics.Level = .debug,
        fields: [OpalDiagnostics.Field] = []
    ) {
        OpalDiagnostics.logger(category: Category.oracle).record(
            event: event,
            level: level,
            fields: fields
        )
    }

    static func publicField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: value)
    }

    static func publicField(_ name: String, _ value: Int) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value)
    }

    static func publicField(_ name: String, _ value: Int64) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: String(value))
    }

    static func privateField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value, privacy: .private)
    }

    static func operationField(_ operation: String) -> OpalDiagnostics.Field {
        publicField(Field.operation, operation)
    }

    static func moduleField(_ module: String) -> OpalDiagnostics.Field {
        publicField(Field.module, module)
    }

    static func makeMessageFields(for message: OpalHedgeOraclePriceMessage) -> [OpalDiagnostics.Field] {
        [
            publicField(Field.byteCount, message.rawData.count),
            publicField(Field.messageTimestamp, message.messageTimestamp),
            publicField(Field.messageSequence, message.messageSequence),
            publicField(Field.priceSequence, message.priceSequence),
            publicField(Field.priceValue, message.priceValue)
        ]
    }

    static func makeErrorFields(
        for error: Swift.Error,
        errorCategory explicitErrorCategory: String? = nil
    ) -> [OpalDiagnostics.Field] {
        [
            publicField(Field.errorCode, errorCode(for: error)),
            publicField(
                Field.errorCategory,
                explicitErrorCategory ?? errorCategory(for: error)
            ),
            privateField(Field.errorMessage, (error as NSError).localizedDescription)
        ]
    }

    static func errorCode(for error: Swift.Error) -> String {
        switch error {
        case let error as OpalHedgeOracleMessageError:
            return errorCode(for: error)
        case let error as OpalHedgeOracleSignatureVerificationError:
            return errorCode(for: error)
        default:
            return ErrorCode.unknown
        }
    }

    static func errorCode(for error: OpalHedgeOracleMessageError) -> String {
        switch error {
        case .invalidHexLength:
            return ErrorCode.oracleInvalidHexLength
        case .invalidHexCharacter:
            return ErrorCode.oracleInvalidHexCharacter
        case .invalidMessageLength:
            return ErrorCode.oracleInvalidMessageLength
        case .invalidScriptInteger:
            return ErrorCode.oracleInvalidScriptInteger
        case .invalidPrice:
            return ErrorCode.oracleInvalidPrice
        }
    }

    static func errorCode(for error: OpalHedgeOracleSignatureVerificationError) -> String {
        switch error {
        case .invalidPublicKey:
            return ErrorCode.oracleInvalidPublicKey
        case .invalidSignature:
            return ErrorCode.oracleInvalidSignature
        case .invalidDigest:
            return ErrorCode.oracleInvalidDigest
        case .cryptographyFailure:
            return ErrorCode.oracleCryptographyFailure
        }
    }

    static func errorCategory(for error: Swift.Error) -> String {
        switch error {
        case is OpalHedgeOracleMessageError:
            return "oracle_message"
        case is OpalHedgeOracleSignatureVerificationError:
            return "oracle_signature"
        default:
            return "unknown"
        }
    }
}
