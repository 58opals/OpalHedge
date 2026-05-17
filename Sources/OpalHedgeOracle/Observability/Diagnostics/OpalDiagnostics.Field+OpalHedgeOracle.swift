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
        OpalDiagnostics.Field(name: name, value: value)
    }

    static func publicField(_ name: String, _ value: Int64) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: String(value))
    }

    static func privateField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value, privacy: .private)
    }

    static func operationField(_ operation: String) -> OpalDiagnostics.Field {
        publicField(Self.operation, operation)
    }

    static func moduleField(_ module: String) -> OpalDiagnostics.Field {
        publicField(Self.module, module)
    }

    static func makeMessageFields(for message: OpalHedgeOraclePriceMessage) -> [OpalDiagnostics.Field] {
        [
            publicField(Self.byteCount, message.rawData.count),
            publicField(Self.messageTimestamp, message.messageTimestamp),
            publicField(Self.messageSequence, message.messageSequence),
            publicField(Self.priceSequence, message.priceSequence),
            publicField(Self.priceValue, message.priceValue)
        ]
    }

    static func makeErrorFields(for error: Swift.Error, errorCategory explicitErrorCategory: String? = nil) -> [OpalDiagnostics.Field] {
        [
            publicField(Self.errorCode, errorCode(for: error)),
            publicField(Self.errorCategory, explicitErrorCategory ?? errorCategory(for: error)),
            privateField(Self.errorMessage, (error as NSError).localizedDescription)
        ]
    }

    static func errorCode(for error: Swift.Error) -> String {
        switch error {
        case let error as OpalHedgeOracleMessageError:
            return errorCode(for: error)
        case let error as OpalHedgeOracleSignatureVerificationError:
            return errorCode(for: error)
        default:
            return OpalHedgeOracleDiagnosticErrorCode.unknown
        }
    }

    static func errorCode(for error: OpalHedgeOracleMessageError) -> String {
        switch error {
        case .invalidHexLength:
            return OpalHedgeOracleDiagnosticErrorCode.invalidHexLength
        case .invalidHexCharacter:
            return OpalHedgeOracleDiagnosticErrorCode.invalidHexCharacter
        case .invalidMessageLength:
            return OpalHedgeOracleDiagnosticErrorCode.invalidMessageLength
        case .invalidScriptInteger:
            return OpalHedgeOracleDiagnosticErrorCode.invalidScriptInteger
        case .invalidPrice:
            return OpalHedgeOracleDiagnosticErrorCode.invalidPrice
        }
    }

    static func errorCode(for error: OpalHedgeOracleSignatureVerificationError) -> String {
        switch error {
        case .invalidPublicKey:
            return OpalHedgeOracleDiagnosticErrorCode.invalidPublicKey
        case .invalidSignature:
            return OpalHedgeOracleDiagnosticErrorCode.invalidSignature
        case .invalidDigest:
            return OpalHedgeOracleDiagnosticErrorCode.invalidDigest
        case .cryptographyFailure:
            return OpalHedgeOracleDiagnosticErrorCode.cryptographyFailure
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
