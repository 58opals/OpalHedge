// OpalHedgeOracleDiagnosticErrorCode.swift

enum OpalHedgeOracleDiagnosticErrorCode {
    static let unknown = "unknown"
    static let invalidHexLength = "oracle.invalid_hex_length"
    static let invalidHexCharacter = "oracle.invalid_hex_character"
    static let invalidMessageLength = "oracle.invalid_message_length"
    static let invalidScriptInteger = "oracle.invalid_script_integer"
    static let invalidPrice = "oracle.invalid_price"
    static let invalidPublicKey = "oracle.invalid_public_key"
    static let invalidSignature = "oracle.invalid_signature"
    static let invalidDigest = "oracle.invalid_digest"
    static let cryptographyFailure = "oracle.cryptography_failure"
}
