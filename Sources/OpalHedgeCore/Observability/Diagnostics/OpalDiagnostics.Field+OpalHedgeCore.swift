// OpalDiagnostics.Field+OpalHedgeCore.swift

import Foundation
import OpalDiagnostics

extension OpalDiagnostics.Field {
    static let operation = "operation"
    static let module = "module"
    static let constraintCategory = "constraint_category"
    static let errorCategory = "error_category"
    static let errorCode = "error_code"
    static let errorMessage = "error_message"
    static let fundingCount = "funding_count"
    static let feeCount = "fee_count"
    static let byteCount = "byte_count"
    static let payloadType = "payload_type"
    static let settlementKind = "settlement_kind"
    static let settlementPrice = "settlement_price"
    static let satoshiCount = "satoshi_count"

    static func publicField(_ name: String, _ value: String) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: value)
    }

    static func publicField(_ name: String, _ value: Int) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, value: value, privacy: .public)
    }

    static func publicField(_ name: String, _ value: Int64) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: String(value))
    }

    static func operationField(_ operation: String) -> OpalDiagnostics.Field {
        publicField(Self.operation, operation)
    }

    static func moduleField(_ module: String) -> OpalDiagnostics.Field {
        publicField(Self.module, module)
    }

    static func makeErrorFields(for error: Swift.Error) -> [OpalDiagnostics.Field] {
        [
            OpalDiagnostics.Field.errorCode(errorCode(for: error)),
            OpalDiagnostics.Field.errorType(error),
            publicField(Self.errorCategory, errorCategory(for: error)),
            OpalDiagnostics.Field.errorMessage((error as NSError).localizedDescription)
        ]
    }

    static func makeConstraintFields(for error: Swift.Error) -> [OpalDiagnostics.Field] {
        guard let constraintError = error as? OpalHedgeCoreContractConstraintError else {
            return []
        }

        return [
            publicField(Self.constraintCategory, constraintCategory(for: constraintError))
        ]
    }

    static func errorCode(for error: Swift.Error) -> OpalDiagnostics.ErrorCode {
        switch error {
        case let error as OpalHedgeCoreContractConstraintError:
            return errorCode(for: error)
        case let error as OpalHedgeCoreContractDataDocumentError:
            return errorCode(for: error)
        case is OpalHedgeCoreSettlementConditionError:
            return OpalDiagnostics.ErrorCode(rawValue: "settlement.condition_invalid")
        case is OpalHedgeCoreSettlementCalculationError:
            return OpalDiagnostics.ErrorCode(rawValue: "settlement.payout_invalid")
        default:
            return OpalDiagnostics.ErrorCode(rawValue: "unknown")
        }
    }

    static func errorCode(for error: OpalHedgeCoreContractConstraintError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .makerSideMustOpposeTaker,
             .invalidPositiveInteger,
             .invalidNonnegativeInteger,
             .invalidBooleanInteger,
             .invalidNominalUnits,
             .invalidLiquidationMultiplier,
             .invalidRoundedInteger,
             .invalidPublicKeyHex,
             .invalidTransactionHashHex,
             .invalidOracleMessageHex,
             .inconsistentOracleMessageComponent,
             .invalidOracleSignatureHex,
             .invalidPayoutAddress,
             .invalidLockScriptHex,
             .unsupportedLockScriptTemplate,
             .inconsistentPayoutAddressLockScript,
             .inconsistentPayoutAddressNetwork,
             .lowLiquidationPriceNotBelowStart,
             .highLiquidationPriceNotAboveStart,
             .invalidPayoutSatoshis,
             .contractSatoshisExceedMaximum,
             .insufficientDivisionPrecision,
             .unsafeShortPayoutAtHighLiquidation,
             .unsafeLongPayoutAtLowLiquidation,
             .inconsistentContractFundingAmount,
             .invalidContractFunding:
            return OpalDiagnostics.ErrorCode(rawValue: "contract.constraint_validation_failed")
        }
    }

    static func errorCode(for error: OpalHedgeCoreContractDataDocumentError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .invalidJson:
            return OpalDiagnostics.ErrorCode(rawValue: "data_document.invalid_json")
        case .invalidRootObject:
            return OpalDiagnostics.ErrorCode(rawValue: "data_document.invalid_root_object")
        case .missingField:
            return OpalDiagnostics.ErrorCode(rawValue: "data_document.missing_field")
        case .invalidFieldType:
            return OpalDiagnostics.ErrorCode(rawValue: "data_document.invalid_field_type")
        case .invalidContractSide:
            return OpalDiagnostics.ErrorCode(rawValue: "data_document.invalid_contract_side")
        case .invalidSettlementType:
            return OpalDiagnostics.ErrorCode(rawValue: "data_document.invalid_settlement_type")
        }
    }

    static func errorCategory(for error: Swift.Error) -> String {
        switch error {
        case is OpalHedgeCoreContractConstraintError:
            return "constraint"
        case is OpalHedgeCoreContractDataDocumentError:
            return "data_document"
        case is OpalHedgeCoreSettlementConditionError,
             is OpalHedgeCoreSettlementCalculationError:
            return "settlement"
        default:
            return "unknown"
        }
    }

    static func constraintCategory(for error: OpalHedgeCoreContractConstraintError) -> String {
        switch error {
        case .invalidPublicKeyHex,
             .invalidTransactionHashHex,
             .invalidOracleMessageHex,
             .invalidOracleSignatureHex,
             .inconsistentOracleMessageComponent:
            return "cryptography"
        case .invalidPayoutAddress,
             .invalidLockScriptHex,
             .unsupportedLockScriptTemplate,
             .inconsistentPayoutAddressLockScript,
             .inconsistentPayoutAddressNetwork:
            return "bitcoin_cash"
        case .inconsistentContractFundingAmount,
             .invalidContractFunding:
            return "funding"
        case .invalidPayoutSatoshis,
             .contractSatoshisExceedMaximum,
             .insufficientDivisionPrecision,
             .unsafeShortPayoutAtHighLiquidation,
             .unsafeLongPayoutAtLowLiquidation:
            return "execution_safety"
        default:
            return "parameters"
        }
    }
}
