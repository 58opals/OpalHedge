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
        OpalDiagnostics.Field(name: name, value: value)
    }

    static func privateField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value, privacy: .private)
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
            publicField(Self.errorCode, errorCode(for: error)),
            publicField(Self.errorCategory, errorCategory(for: error)),
            privateField(Self.errorMessage, (error as NSError).localizedDescription)
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
            return OpalHedgeBitcoinCashDiagnosticErrorCode.unknown
        }
    }

    static func errorCode(for error: OpalHedgeBitcoinCashContractAddressError) -> String {
        switch error {
        case .invalidRedeemScriptHex:
            return OpalHedgeBitcoinCashDiagnosticErrorCode.invalidRedeemScriptHex
        case .invalidScriptHashByteCount:
            return OpalHedgeBitcoinCashDiagnosticErrorCode.invalidScriptHashByteCount
        }
    }

    static func errorCode(for error: OpalHedgeBitcoinCashScriptEncodingError) -> String {
        switch error {
        case .dataPushTooLarge:
            return OpalHedgeBitcoinCashDiagnosticErrorCode.dataPushTooLarge
        }
    }

    static func errorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractParameterError) -> String {
        switch error {
        case .invalidHex:
            return OpalHedgeBitcoinCashDiagnosticErrorCode.invalidHex
        case .invalidCompressedPublicKey:
            return OpalHedgeBitcoinCashDiagnosticErrorCode.invalidCompressedPublicKey
        case .invalidLockScript:
            return OpalHedgeBitcoinCashDiagnosticErrorCode.invalidLockScript
        case .invalidPositiveInteger:
            return OpalHedgeBitcoinCashDiagnosticErrorCode.invalidPositiveInteger
        case .invalidNonnegativeInteger:
            return OpalHedgeBitcoinCashDiagnosticErrorCode.invalidNonnegativeInteger
        case .invalidBooleanInteger:
            return OpalHedgeBitcoinCashDiagnosticErrorCode.invalidBooleanInteger
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
