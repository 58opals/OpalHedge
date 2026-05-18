// OpalDiagnostics.Field+OpalHedgeBitcoinCashErrorCodes.swift

import OpalDiagnostics
import OpalHedgeBitcoinCash

extension OpalDiagnostics.Field {
    static func bitcoinCashContractAddressErrorCode(for error: OpalHedgeBitcoinCashContractAddressError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .invalidRedeemScriptHex:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.invalid_redeem_script_hex")
        case .invalidScriptHashByteCount:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.invalid_script_hash_byte_count")
        }
    }

    static func bitcoinCashScriptEncodingErrorCode(for error: OpalHedgeBitcoinCashScriptEncodingError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .dataPushTooLarge:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.script.data_push_too_large")
        }
    }

    static func bitcoinCashParameterErrorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractParameterError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .invalidHex:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.parameter.invalid_hex")
        case .invalidCompressedPublicKey:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.parameter.invalid_compressed_public_key")
        case .invalidLockScript:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.parameter.invalid_lock_script")
        case .invalidPositiveInteger:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.parameter.invalid_positive_integer")
        case .invalidNonnegativeInteger:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.parameter.invalid_nonnegative_integer")
        case .invalidBooleanInteger:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.parameter.invalid_boolean_integer")
        }
    }
}
