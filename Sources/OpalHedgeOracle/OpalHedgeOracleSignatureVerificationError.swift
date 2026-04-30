// OpalHedgeOracleSignatureVerificationError.swift

public enum OpalHedgeOracleSignatureVerificationError: Error, Sendable, Equatable {
    case invalidPublicKey
    case invalidSignature
    case invalidDigest
    case cryptographyFailure
}
