// OpalDiagnostics.Field+OpalHedgeBitcoinCash.swift

import Foundation
import OpalDiagnostics

extension OpalDiagnostics.Field {
    static let operation = "operation"
    static let module = "module"
    static let network = "network"
    static let errorCategory = "error_category"
    static let errorCode = "error_code"
    static let errorMessage = "error_message"
    static let byteCount = "byte_count"
    static let pushCount = "push_count"
    static let payloadType = "payload_type"

    static func publicField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: value)
    }

    static func publicField(_ name: String, _ value: Int) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value, privacy: .public)
    }

    static func operationField(_ operation: String) -> OpalDiagnostics.Field {
        publicField(Self.operation, operation)
    }

    static func moduleField(_ module: String) -> OpalDiagnostics.Field {
        publicField(Self.module, module)
    }

    static func networkField(_ network: OpalHedgeBitcoinCashNetwork) -> OpalDiagnostics.Field {
        publicField(Self.network, network.rawValue)
    }

    static func makeErrorFields(for error: Swift.Error) -> [OpalDiagnostics.Field] {
        [
            OpalDiagnostics.Field.errorCode(errorCode(for: error)),
            OpalDiagnostics.Field.errorType(error),
            publicField(Self.errorCategory, errorCategory(for: error)),
            OpalDiagnostics.Field.errorMessage((error as NSError).localizedDescription)
        ]
    }

    static func errorCode(for error: Swift.Error) -> OpalDiagnostics.ErrorCode {
        switch error {
        case let error as OpalHedgeBitcoinCashContractAddressError:
            return errorCode(for: error)
        case let error as OpalHedgeBitcoinCashScriptEncodingError:
            return errorCode(for: error)
        case let error as OpalHedgeBitcoinCashAnyHedgeContractParameterError:
            return errorCode(for: error)
        default:
            return OpalDiagnostics.ErrorCode(rawValue: "unknown")
        }
    }

    static func errorCode(for error: OpalHedgeBitcoinCashContractAddressError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .invalidRedeemScriptHex:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.invalid_redeem_script_hex")
        case .invalidScriptHashByteCount:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.invalid_script_hash_byte_count")
        }
    }

    static func errorCode(for error: OpalHedgeBitcoinCashScriptEncodingError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .dataPushTooLarge:
            return OpalDiagnostics.ErrorCode(rawValue: "bitcoin_cash.script.data_push_too_large")
        }
    }

    static func errorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractParameterError) -> OpalDiagnostics.ErrorCode {
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
