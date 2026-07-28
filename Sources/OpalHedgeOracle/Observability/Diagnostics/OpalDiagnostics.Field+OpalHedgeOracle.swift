// OpalDiagnostics.Field+OpalHedgeOracle.swift

import Foundation
import OpalDiagnostics

extension OpalDiagnostics.Field {
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

    static func publicField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: value)
    }

    static func publicField(_ name: String, _ value: Int) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value, privacy: .public)
    }

    static func publicField(_ name: String, _ value: Int64) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: String(value))
    }

    static func operationField(_ operation: String) -> OpalDiagnostics.Field {
        publicField(Self.operation, operation)
    }

    static func moduleField(_ module: String) -> OpalDiagnostics.Field {
        publicField(Self.module, module)
    }

    static func makeOraclePriceMessageSummaryFields(
        for message: OpalHedgeOraclePriceMessage
    ) -> [OpalDiagnostics.Field] {
        [
            publicField(Self.byteCount, message.rawMessageData.count),
            publicField(Self.messageTimestamp, message.messageTimestamp),
            publicField(Self.messageSequence, message.messageSequence),
            publicField(Self.priceSequence, message.priceSequence),
            publicField(Self.priceValue, message.priceValue)
        ]
    }

    static func makeErrorFields(for error: Swift.Error, errorCategory explicitErrorCategory: String? = nil) -> [OpalDiagnostics.Field] {
        [
            OpalDiagnostics.Field.errorCode(errorCode(for: error)),
            OpalDiagnostics.Field.errorType(error),
            publicField(Self.errorCategory, explicitErrorCategory ?? errorCategory(for: error)),
            OpalDiagnostics.Field.errorMessage((error as NSError).localizedDescription)
        ]
    }

    static func errorCode(for error: Swift.Error) -> OpalDiagnostics.ErrorCode {
        switch error {
        case let error as OpalHedgeOracleMessageError:
            return errorCode(for: error)
        case let error as OpalHedgeOracleSignatureVerificationError:
            return errorCode(for: error)
        default:
            return OpalDiagnostics.ErrorCode(rawValue: "unknown")
        }
    }

    static func errorCode(for error: OpalHedgeOracleMessageError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .invalidHexLength:
            return OpalDiagnostics.ErrorCode(rawValue: "oracle.invalid_hex_length")
        case .invalidHexCharacter:
            return OpalDiagnostics.ErrorCode(rawValue: "oracle.invalid_hex_character")
        case .invalidMessageLength:
            return OpalDiagnostics.ErrorCode(rawValue: "oracle.invalid_message_length")
        case .invalidScriptInteger:
            return OpalDiagnostics.ErrorCode(rawValue: "oracle.invalid_script_integer")
        case .invalidPrice:
            return OpalDiagnostics.ErrorCode(rawValue: "oracle.invalid_price")
        }
    }

    static func errorCode(for error: OpalHedgeOracleSignatureVerificationError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .invalidPublicKey:
            return OpalDiagnostics.ErrorCode(rawValue: "oracle.invalid_public_key")
        case .invalidSignature:
            return OpalDiagnostics.ErrorCode(rawValue: "oracle.invalid_signature")
        case .invalidDigest:
            return OpalDiagnostics.ErrorCode(rawValue: "oracle.invalid_digest")
        case .cryptographyFailure:
            return OpalDiagnostics.ErrorCode(rawValue: "oracle.cryptography_failure")
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
