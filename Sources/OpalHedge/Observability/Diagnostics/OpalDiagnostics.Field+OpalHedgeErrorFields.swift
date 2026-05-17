// OpalDiagnostics.Field+OpalHedgeErrorFields.swift

import Foundation
import OpalDiagnostics
import OpalHedgeBitcoinCash
import OpalHedgeCore
import OpalHedgeOracle

extension OpalDiagnostics.Field {
    static func publicField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: value)
    }

    static func publicField(_ name: String, _ value: Int) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value)
    }

    static func publicField(_ name: String, _ value: Int64) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: String(value))
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

    static func settlementKindField(_ kind: OpalHedgeCoreSettlementKind) -> OpalDiagnostics.Field {
        publicField(Self.settlementKind, kind.rawValue)
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
        case OpalHedgeStartingPriceProofError.invalidSignature,
             OpalHedgeSettlementOracleProofError.invalidSignature:
            return OpalHedgeDiagnosticErrorCode.oracleInvalidSignature
        case let error as OpalHedgeOracleMessageError:
            return oracleErrorCode(for: error)
        case let error as OpalHedgeOracleSignatureVerificationError:
            return oracleSignatureErrorCode(for: error)
        case let error as OpalHedgeCoreContractConstraintError:
            return coreConstraintErrorCode(for: error)
        case let error as OpalHedgeCoreContractDataDocumentError:
            return coreDataDocumentErrorCode(for: error)
        case let error as OpalHedgeBitcoinCashContractAddressError:
            return bitcoinCashContractAddressErrorCode(for: error)
        case let error as OpalHedgeBitcoinCashScriptEncodingError:
            return bitcoinCashScriptEncodingErrorCode(for: error)
        case let error as OpalHedgeBitcoinCashAnyHedgeContractParameterError:
            return bitcoinCashParameterErrorCode(for: error)
        case is OpalHedgeBitcoinCashAnyHedgeContractFundingRequestError:
            return OpalHedgeDiagnosticErrorCode.fundingAlreadyExists
        case let error as OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError:
            return fundingOutputErrorCode(for: error)
        case let error as OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError:
            return fundingRecordErrorCode(for: error)
        case let error as OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError:
            return settlementRecordErrorCode(for: error)
        case is OpalHedgeCoreSettlementConditionError:
            return OpalHedgeDiagnosticErrorCode.settlementConditionInvalid
        case is OpalHedgeCoreSettlementCalculationError:
            return OpalHedgeDiagnosticErrorCode.settlementPayoutInvalid
        default:
            return OpalHedgeDiagnosticErrorCode.unknown
        }
    }

    static func errorCategory(for error: Swift.Error) -> String {
        switch error {
        case is OpalHedgeStartingPriceProofError,
             is OpalHedgeSettlementOracleProofError,
             is OpalHedgeOracleMessageError,
             is OpalHedgeOracleSignatureVerificationError:
            return "oracle"
        case is OpalHedgeCoreContractConstraintError:
            return "constraint"
        case is OpalHedgeCoreContractDataDocumentError:
            return "data_document"
        case is OpalHedgeBitcoinCashContractAddressError,
             is OpalHedgeBitcoinCashScriptEncodingError,
             is OpalHedgeBitcoinCashAnyHedgeContractParameterError:
            return "bitcoin_cash"
        case is OpalHedgeBitcoinCashAnyHedgeContractFundingRequestError,
             is OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError,
             is OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError:
            return "funding"
        case is OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError,
             is OpalHedgeCoreSettlementConditionError,
             is OpalHedgeCoreSettlementCalculationError:
            return "settlement"
        default:
            return "unknown"
        }
    }
}
