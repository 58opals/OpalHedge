// OpalHedgeCoreContractConstraintPolicy.swift

public enum OpalHedgeCoreContractConstraintPolicy {
    public static let cashAddressPayToPublicKeyHashPayloadLength = 42
    public static let compressedPublicKeyHexCharacterCount = 66
    public static let dustLimitSatoshis: Int64 = 1_332
    public static let satoshisPerBitcoinCash: Int64 = 100_000_000
    public static let maxContractSatoshis: Int64 = 10_000_000_000_000
    public static let minPriceOracleUnitsPerBitcoinCash: Int64 = 1
    public static let maxPriceOracleUnitsPerBitcoinCash: Int64 = 2_147_483_647
    public static let minIntegerDivisionPrecisionSteps: Int64 = 500
    public static let maxFourByteScriptInteger: Int64 = 2_147_483_647
    public static let oraclePriceMessageHexCharacterCount = 32
    public static let payToPublicKeyHashLockScriptHexCharacterCount = 50
    public static let payToPublicKeyHashLockScriptPrefixHex = "76a914"
    public static let payToPublicKeyHashLockScriptSuffixHex = "88ac"
    public static let schnorrSignatureHexCharacterCount = 128
}
