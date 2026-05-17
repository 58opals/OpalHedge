// OpalHedgeBitcoinCashDiagnosticErrorCode.swift

enum OpalHedgeBitcoinCashDiagnosticErrorCode {
    static let unknown = "unknown"
    static let invalidRedeemScriptHex = "bitcoin_cash.invalid_redeem_script_hex"
    static let invalidScriptHashByteCount = "bitcoin_cash.invalid_script_hash_byte_count"
    static let dataPushTooLarge = "bitcoin_cash.script.data_push_too_large"
    static let invalidHex = "bitcoin_cash.parameter.invalid_hex"
    static let invalidCompressedPublicKey = "bitcoin_cash.parameter.invalid_compressed_public_key"
    static let invalidLockScript = "bitcoin_cash.parameter.invalid_lock_script"
    static let invalidPositiveInteger = "bitcoin_cash.parameter.invalid_positive_integer"
    static let invalidNonnegativeInteger = "bitcoin_cash.parameter.invalid_nonnegative_integer"
    static let invalidBooleanInteger = "bitcoin_cash.parameter.invalid_boolean_integer"
}
