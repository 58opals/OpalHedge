// OpalDiagnostics.Field+OpalHedgeOracleErrorCodes.swift

import OpalDiagnostics
import OpalHedgeOracle

extension OpalDiagnostics.Field {
    static func oracleErrorCode(for error: OpalHedgeOracleMessageError) -> OpalDiagnostics.ErrorCode {
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

    static func oracleSignatureErrorCode(for error: OpalHedgeOracleSignatureVerificationError) -> OpalDiagnostics.ErrorCode {
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
}
