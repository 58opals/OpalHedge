// OpalHedgeBitcoinCashAnyHedgeContractParameterData~Validation.swift

import Foundation

extension OpalHedgeBitcoinCashAnyHedgeContractParameterData {
    static func validateCompressedPublicKey(_ value: Data, name: String) throws {
        guard value.count == compressedPublicKeyByteCount,
              let firstByte = value.first,
              compressedPublicKeyPrefixes.contains(firstByte) else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidCompressedPublicKey(name: name, byteCount: value.count)
        }
    }

    static func validatePayToPublicKeyHashLockScript(
        _ value: Data,
        name: String
    ) throws {
        guard value.count == payToPublicKeyHashLockScriptByteCount,
              value.starts(with: payToPublicKeyHashLockScriptPrefix),
              value.suffix(payToPublicKeyHashLockScriptSuffix.count) ==
              payToPublicKeyHashLockScriptSuffix else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidLockScript(name: name, byteCount: value.count)
        }
    }

    static func validatePositiveInteger(_ value: Int64, name: String) throws {
        guard value > 0 else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidPositiveInteger(name: name, value: value)
        }
    }

    static func validateFourBytePositiveScriptInteger(
        _ value: Int64,
        name: String
    ) throws {
        try validatePositiveInteger(value, name: name)
        guard value <= maxFourByteScriptInteger else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidPositiveInteger(name: name, value: value)
        }
    }

    static func validateIncreasingIntegerRange(
        lower: Int64,
        upper: Int64,
        upperName: String
    ) throws {
        guard upper > lower else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidPositiveInteger(name: upperName, value: upper)
        }
    }

    static func validateNonnegativeInteger(_ value: Int64, name: String) throws {
        guard value >= 0 else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidNonnegativeInteger(name: name, value: value)
        }
    }

    static func validateBooleanInteger(_ value: Int64, name: String) throws {
        guard value == 0 || value == 1 else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidBooleanInteger(name: name, value: value)
        }
    }

    static func validatePayoutSatoshis(_ value: Int64) throws {
        guard value >= dustLimitSatoshis,
              value <= maxContractSatoshis else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidPositiveInteger(name: "payoutSats", value: value)
        }
    }

    private static let compressedPublicKeyByteCount = 33
    private static let payToPublicKeyHashLockScriptByteCount = 25
    private static let maxFourByteScriptInteger = Int64(Int32.max)
    private static let dustLimitSatoshis: Int64 = 1_332
    private static let maxContractSatoshis: Int64 = 10_000_000_000_000

    private static let payToPublicKeyHashLockScriptPrefix = Data([0x76, 0xa9, 0x14])
    private static let payToPublicKeyHashLockScriptSuffix = Data([0x88, 0xac])
    private static let compressedPublicKeyPrefixes: Set<UInt8> = [0x02, 0x03]
}
