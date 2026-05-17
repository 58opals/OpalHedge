// OpalDiagnostics.Field+OpalHedgeCoreErrorCodes.swift

import OpalDiagnostics
import OpalHedgeCore

extension OpalDiagnostics.Field {
    static func coreConstraintErrorCode(for error: OpalHedgeCoreContractConstraintError) -> String {
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
            return OpalHedgeDiagnosticErrorCode.contractConstraintValidationFailed
        }
    }

    static func coreDataDocumentErrorCode(for error: OpalHedgeCoreContractDataDocumentError) -> String {
        switch error {
        case .invalidJson:
            return OpalHedgeDiagnosticErrorCode.dataDocumentInvalidJson
        case .invalidRootObject:
            return OpalHedgeDiagnosticErrorCode.dataDocumentInvalidRootObject
        case .missingField:
            return OpalHedgeDiagnosticErrorCode.dataDocumentMissingField
        case .invalidFieldType:
            return OpalHedgeDiagnosticErrorCode.dataDocumentInvalidFieldType
        case .invalidContractSide:
            return OpalHedgeDiagnosticErrorCode.dataDocumentInvalidContractSide
        case .invalidSettlementType:
            return OpalHedgeDiagnosticErrorCode.dataDocumentInvalidSettlementType
        }
    }
}
