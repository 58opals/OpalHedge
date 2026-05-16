// OpalHedgeCoreDiagnostics.swift

import Foundation
import OpalDiagnostics

enum OpalHedgeCoreDiagnostics {
    enum Category {
        static let contract = OpalDiagnostics.Category(rawValue: "hedge.contract")
        static let dataDocument = OpalDiagnostics.Category(rawValue: "hedge.data_document")
        static let settlement = OpalDiagnostics.Category(rawValue: "hedge.settlement")
    }

    enum Event {
        static let contractPlanCreated = OpalDiagnostics.Event(rawValue: "opalhedge.contract.plan.created")
        static let contractPlanCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.contract.plan.creation_failed")
        static let contractConstraintsValidated = OpalDiagnostics.Event(rawValue: "opalhedge.contract.constraints.validated")
        static let contractConstraintValidationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.contract.constraints.validation_failed")
        static let dataDocumentEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.encoded")
        static let dataDocumentEncodeFailed = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.encode_failed")
        static let dataDocumentDecoded = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.decoded")
        static let dataDocumentDecodeFailed = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.decode_failed")
        static let settlementConditionResolved = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.condition.resolved")
        static let settlementConditionResolutionFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.condition.resolution_failed")
        static let settlementPayoutCalculated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.payout.calculated")
        static let settlementPayoutCalculationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.payout.calculation_failed")
    }

    enum Field {
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
    }

    enum ErrorCode {
        static let unknown = "unknown"
        static let contractPlanCreationFailed = "contract.plan_creation_failed"
        static let contractConstraintValidationFailed = "contract.constraint_validation_failed"
        static let dataDocumentInvalidJson = "data_document.invalid_json"
        static let dataDocumentInvalidRootObject = "data_document.invalid_root_object"
        static let dataDocumentMissingField = "data_document.missing_field"
        static let dataDocumentInvalidFieldType = "data_document.invalid_field_type"
        static let dataDocumentInvalidContractSide = "data_document.invalid_contract_side"
        static let dataDocumentInvalidSettlementType = "data_document.invalid_settlement_type"
        static let dataDocumentEncodeFailed = "data_document.encode_failed"
        static let dataDocumentDecodeFailed = "data_document.decode_failed"
        static let settlementConditionInvalid = "settlement.condition_invalid"
        static let settlementPayoutInvalid = "settlement.payout_invalid"
    }

    static func record(
        _ event: OpalDiagnostics.Event,
        category: OpalDiagnostics.Category,
        level: OpalDiagnostics.Level = .debug,
        fields: [OpalDiagnostics.Field] = []
    ) {
        OpalDiagnostics.logger(category: category).record(
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

    static func publicField(_ name: String, _ value: Int64) -> OpalDiagnostics.Field {
        OpalDiagnostics.Field(name: name, publicValue: String(value))
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

    static func makeErrorFields(for error: Swift.Error) -> [OpalDiagnostics.Field] {
        [
            publicField(Field.errorCode, errorCode(for: error)),
            publicField(Field.errorCategory, errorCategory(for: error)),
            privateField(Field.errorMessage, (error as NSError).localizedDescription)
        ]
    }

    static func makeConstraintFields(for error: Swift.Error) -> [OpalDiagnostics.Field] {
        guard let constraintError = error as? OpalHedgeCoreContractConstraintError else {
            return []
        }

        return [
            publicField(Field.constraintCategory, constraintCategory(for: constraintError))
        ]
    }

    static func errorCode(for error: Swift.Error) -> String {
        switch error {
        case let error as OpalHedgeCoreContractConstraintError:
            return errorCode(for: error)
        case let error as OpalHedgeCoreContractDataDocumentError:
            return errorCode(for: error)
        case is OpalHedgeCoreSettlementConditionError:
            return ErrorCode.settlementConditionInvalid
        case is OpalHedgeCoreSettlementCalculationError:
            return ErrorCode.settlementPayoutInvalid
        default:
            return ErrorCode.unknown
        }
    }

    static func errorCode(for error: OpalHedgeCoreContractConstraintError) -> String {
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
            return ErrorCode.contractConstraintValidationFailed
        }
    }

    static func errorCode(for error: OpalHedgeCoreContractDataDocumentError) -> String {
        switch error {
        case .invalidJson:
            return ErrorCode.dataDocumentInvalidJson
        case .invalidRootObject:
            return ErrorCode.dataDocumentInvalidRootObject
        case .missingField:
            return ErrorCode.dataDocumentMissingField
        case .invalidFieldType:
            return ErrorCode.dataDocumentInvalidFieldType
        case .invalidContractSide:
            return ErrorCode.dataDocumentInvalidContractSide
        case .invalidSettlementType:
            return ErrorCode.dataDocumentInvalidSettlementType
        }
    }

    static func errorCategory(for error: Swift.Error) -> String {
        switch error {
        case is OpalHedgeCoreContractConstraintError:
            return "constraint"
        case is OpalHedgeCoreContractDataDocumentError:
            return "data_document"
        case is OpalHedgeCoreSettlementConditionError:
            return "settlement_condition"
        case is OpalHedgeCoreSettlementCalculationError:
            return "settlement_calculation"
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
