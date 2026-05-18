// OpalDiagnostics.Field+OpalHedgeCoreErrorCodes.swift

import OpalDiagnostics
import OpalHedgeCore

extension OpalDiagnostics.Field {
    static func coreConstraintErrorCode(for error: OpalHedgeCoreContractConstraintError) -> OpalDiagnostics.ErrorCode {
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

    static func coreDataDocumentErrorCode(for error: OpalHedgeCoreContractDataDocumentError) -> OpalDiagnostics.ErrorCode {
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
}
