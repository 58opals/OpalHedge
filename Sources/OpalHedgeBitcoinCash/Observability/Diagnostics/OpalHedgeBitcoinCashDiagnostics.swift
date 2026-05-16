// OpalHedgeBitcoinCashDiagnostics.swift

import Foundation
import OpalDiagnostics

enum OpalHedgeBitcoinCashDiagnostics {
    enum Category {
        static let bitcoinCash = OpalDiagnostics.Category(rawValue: "hedge.bitcoin_cash")
    }

    enum Event {
        static let contractAddressEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_address.encoded")
        static let contractAddressEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_address.encoding_failed")
        static let contractParametersEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_parameters.encoded")
        static let contractParameterEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_parameters.encoding_failed")
        static let contractScriptEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_script.encoding_failed")
    }

    enum Field {
        static let operation = "operation"
        static let module = "module"
        static let network = "network"
        static let errorCategory = "error_category"
        static let errorCode = "error_code"
        static let errorMessage = "error_message"
        static let byteCount = "byte_count"
        static let pushCount = "push_count"
        static let payloadType = "payload_type"
    }

    enum ErrorCode {
        static let unknown = "unknown"
        static let bitcoinCashInvalidRedeemScriptHex = "bitcoin_cash.invalid_redeem_script_hex"
        static let bitcoinCashInvalidScriptHashByteCount = "bitcoin_cash.invalid_script_hash_byte_count"
        static let bitcoinCashScriptDataPushTooLarge = "bitcoin_cash.script.data_push_too_large"
        static let bitcoinCashParameterInvalidHex = "bitcoin_cash.parameter.invalid_hex"
        static let bitcoinCashParameterInvalidCompressedPublicKey = "bitcoin_cash.parameter.invalid_compressed_public_key"
        static let bitcoinCashParameterInvalidLockScript = "bitcoin_cash.parameter.invalid_lock_script"
        static let bitcoinCashParameterInvalidPositiveInteger = "bitcoin_cash.parameter.invalid_positive_integer"
        static let bitcoinCashParameterInvalidNonnegativeInteger = "bitcoin_cash.parameter.invalid_nonnegative_integer"
        static let bitcoinCashParameterInvalidBooleanInteger = "bitcoin_cash.parameter.invalid_boolean_integer"
    }

    static func record(
        _ event: OpalDiagnostics.Event,
        level: OpalDiagnostics.Level = .debug,
        fields: [OpalDiagnostics.Field] = []
    ) {
        OpalDiagnostics.logger(category: Category.bitcoinCash).record(
            event: event,
            level: level,
            fields: fields
        )
    }

    static func publicField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: value)
    }

    static func publicField(_ name: String, _ value: Int) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value)
    }

    static func privateField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value, privacy: .private)
    }

    static func operationField(_ operation: String) -> OpalDiagnostics.Field {
        publicField(Field.operation, operation)
    }

    static func moduleField(_ module: String) -> OpalDiagnostics.Field {
        publicField(Field.module, module)
    }

    static func networkField(_ network: OpalHedgeBitcoinCashNetwork) -> OpalDiagnostics.Field {
        publicField(Field.network, network.rawValue)
    }

    static func makeErrorFields(for error: Swift.Error) -> [OpalDiagnostics.Field] {
        [
            publicField(Field.errorCode, errorCode(for: error)),
            publicField(Field.errorCategory, errorCategory(for: error)),
            privateField(Field.errorMessage, (error as NSError).localizedDescription)
        ]
    }

    static func errorCode(for error: Swift.Error) -> String {
        switch error {
        case let error as OpalHedgeBitcoinCashContractAddressError:
            return errorCode(for: error)
        case let error as OpalHedgeBitcoinCashScriptEncodingError:
            return errorCode(for: error)
        case let error as OpalHedgeBitcoinCashAnyHedgeContractParameterError:
            return errorCode(for: error)
        default:
            return ErrorCode.unknown
        }
    }

    static func errorCode(for error: OpalHedgeBitcoinCashContractAddressError) -> String {
        switch error {
        case .invalidRedeemScriptHex:
            return ErrorCode.bitcoinCashInvalidRedeemScriptHex
        case .invalidScriptHashByteCount:
            return ErrorCode.bitcoinCashInvalidScriptHashByteCount
        }
    }

    static func errorCode(for error: OpalHedgeBitcoinCashScriptEncodingError) -> String {
        switch error {
        case .dataPushTooLarge:
            return ErrorCode.bitcoinCashScriptDataPushTooLarge
        }
    }

    static func errorCode(
        for error: OpalHedgeBitcoinCashAnyHedgeContractParameterError
    ) -> String {
        switch error {
        case .invalidHex:
            return ErrorCode.bitcoinCashParameterInvalidHex
        case .invalidCompressedPublicKey:
            return ErrorCode.bitcoinCashParameterInvalidCompressedPublicKey
        case .invalidLockScript:
            return ErrorCode.bitcoinCashParameterInvalidLockScript
        case .invalidPositiveInteger:
            return ErrorCode.bitcoinCashParameterInvalidPositiveInteger
        case .invalidNonnegativeInteger:
            return ErrorCode.bitcoinCashParameterInvalidNonnegativeInteger
        case .invalidBooleanInteger:
            return ErrorCode.bitcoinCashParameterInvalidBooleanInteger
        }
    }

    static func errorCategory(for error: Swift.Error) -> String {
        switch error {
        case is OpalHedgeBitcoinCashContractAddressError:
            return "contract_address"
        case is OpalHedgeBitcoinCashScriptEncodingError:
            return "script_encoding"
        case is OpalHedgeBitcoinCashAnyHedgeContractParameterError:
            return "contract_parameters"
        default:
            return "unknown"
        }
    }
}
