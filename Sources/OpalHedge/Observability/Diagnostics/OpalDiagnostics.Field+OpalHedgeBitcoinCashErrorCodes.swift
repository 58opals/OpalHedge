// OpalDiagnostics.Field+OpalHedgeBitcoinCashErrorCodes.swift

import OpalDiagnostics
import OpalHedgeBitcoinCash

extension OpalDiagnostics.Field {
    static func bitcoinCashContractAddressErrorCode(for error: OpalHedgeBitcoinCashContractAddressError) -> String {
        switch error {
        case .invalidRedeemScriptHex:
            return OpalHedgeDiagnosticErrorCode.bitcoinCashInvalidRedeemScriptHex
        case .invalidScriptHashByteCount:
            return OpalHedgeDiagnosticErrorCode.bitcoinCashInvalidScriptHashByteCount
        }
    }

    static func bitcoinCashScriptEncodingErrorCode(for error: OpalHedgeBitcoinCashScriptEncodingError) -> String {
        switch error {
        case .dataPushTooLarge:
            return OpalHedgeDiagnosticErrorCode.bitcoinCashScriptDataPushTooLarge
        }
    }

    static func bitcoinCashParameterErrorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractParameterError) -> String {
        switch error {
        case .invalidHex:
            return OpalHedgeDiagnosticErrorCode.bitcoinCashParameterInvalidHex
        case .invalidCompressedPublicKey:
            return OpalHedgeDiagnosticErrorCode.bitcoinCashParameterInvalidCompressedPublicKey
        case .invalidLockScript:
            return OpalHedgeDiagnosticErrorCode.bitcoinCashParameterInvalidLockScript
        case .invalidPositiveInteger:
            return OpalHedgeDiagnosticErrorCode.bitcoinCashParameterInvalidPositiveInteger
        case .invalidNonnegativeInteger:
            return OpalHedgeDiagnosticErrorCode.bitcoinCashParameterInvalidNonnegativeInteger
        case .invalidBooleanInteger:
            return OpalHedgeDiagnosticErrorCode.bitcoinCashParameterInvalidBooleanInteger
        }
    }
}
