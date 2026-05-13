// OpalHedgeBitcoinCashAnyHedgeContractParameterError.swift

public enum OpalHedgeBitcoinCashAnyHedgeContractParameterError: Error, Sendable, Equatable {
    case invalidHex(name: String, value: String)
    case invalidCompressedPublicKey(name: String, byteCount: Int)
    case invalidLockScript(name: String, byteCount: Int)
    case invalidPositiveInteger(name: String, value: Int64)
    case invalidNonnegativeInteger(name: String, value: Int64)
    case invalidBooleanInteger(name: String, value: Int64)
}
