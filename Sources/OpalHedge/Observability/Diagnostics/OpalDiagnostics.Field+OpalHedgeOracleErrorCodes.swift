// OpalDiagnostics.Field+OpalHedgeOracleErrorCodes.swift

import OpalDiagnostics
import OpalHedgeOracle

extension OpalDiagnostics.Field {
    static func oracleErrorCode(for error: OpalHedgeOracleMessageError) -> String {
        switch error {
        case .invalidHexLength:
            return OpalHedgeDiagnosticErrorCode.oracleInvalidHexLength
        case .invalidHexCharacter:
            return OpalHedgeDiagnosticErrorCode.oracleInvalidHexCharacter
        case .invalidMessageLength:
            return OpalHedgeDiagnosticErrorCode.oracleInvalidMessageLength
        case .invalidScriptInteger:
            return OpalHedgeDiagnosticErrorCode.oracleInvalidScriptInteger
        case .invalidPrice:
            return OpalHedgeDiagnosticErrorCode.oracleInvalidPrice
        }
    }

    static func oracleSignatureErrorCode(for error: OpalHedgeOracleSignatureVerificationError) -> String {
        switch error {
        case .invalidPublicKey:
            return OpalHedgeDiagnosticErrorCode.oracleInvalidPublicKey
        case .invalidSignature:
            return OpalHedgeDiagnosticErrorCode.oracleInvalidSignature
        case .invalidDigest:
            return OpalHedgeDiagnosticErrorCode.oracleInvalidDigest
        case .cryptographyFailure:
            return OpalHedgeDiagnosticErrorCode.oracleCryptographyFailure
        }
    }
}
