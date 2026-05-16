// OpalHedgeDiagnostics.swift

import Foundation
import OpalDiagnostics
import OpalHedgeBitcoinCash
import OpalHedgeCore
import OpalHedgeOracle

enum OpalHedgeDiagnostics {
    typealias Diagnostics = OpalHedge.Diagnostics

    enum Category {
        static let contract = Diagnostics.Category.contract
        static let dataDocument = Diagnostics.Category.dataDocument
        static let oracle = Diagnostics.Category.oracle
        static let bitcoinCash = Diagnostics.Category.bitcoinCash
        static let funding = Diagnostics.Category.funding
        static let settlement = Diagnostics.Category.settlement
    }

    enum Event {
        static let contractPlanCreated = Diagnostics.Event.contractPlanCreated
        static let contractPlanCreationFailed = Diagnostics.Event.contractPlanCreationFailed
        static let oracleMessageParsed = Diagnostics.Event.oracleMessageParsed
        static let oracleMessageParseFailed = Diagnostics.Event.oracleMessageParseFailed
        static let oracleSignatureVerified = Diagnostics.Event.oracleSignatureVerified
        static let oracleSignatureVerificationFailed = Diagnostics.Event.oracleSignatureVerificationFailed
        static let startingOracleProofVerified = Diagnostics.Event.startingOracleProofVerified
        static let startingOracleProofVerificationFailed = Diagnostics.Event.startingOracleProofVerificationFailed
        static let settlementOracleProofVerified = Diagnostics.Event.settlementOracleProofVerified
        static let settlementOracleProofVerificationFailed = Diagnostics.Event.settlementOracleProofVerificationFailed
        static let fundingRequestCreated = Diagnostics.Event.fundingRequestCreated
        static let fundingRequestCreationFailed = Diagnostics.Event.fundingRequestCreationFailed
        static let fundingRecordCreated = Diagnostics.Event.fundingRecordCreated
        static let fundingRecordCreationFailed = Diagnostics.Event.fundingRecordCreationFailed
        static let settlementRequestCreated = Diagnostics.Event.settlementRequestCreated
        static let settlementRequestCreationFailed = Diagnostics.Event.settlementRequestCreationFailed
        static let settlementRecordCreated = Diagnostics.Event.settlementRecordCreated
        static let settlementRecordCreationFailed = Diagnostics.Event.settlementRecordCreationFailed
        static let settlementSummaryCreated = Diagnostics.Event.settlementSummaryCreated
        static let transactionHashValidationFailed = Diagnostics.Event.transactionHashValidationFailed
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
        publicField(Diagnostics.Field.operation, operation)
    }

    static func moduleField(_ module: String) -> OpalDiagnostics.Field {
        publicField(Diagnostics.Field.module, module)
    }

    static func networkField(_ network: OpalHedgeBitcoinCashNetwork) -> OpalDiagnostics.Field {
        publicField(Diagnostics.Field.network, network.rawValue)
    }

    static func settlementKindField(
        _ kind: OpalHedgeCoreSettlementKind
    ) -> OpalDiagnostics.Field {
        publicField(Diagnostics.Field.settlementKind, kind.rawValue)
    }

    static func makeErrorFields(for error: Swift.Error) -> [OpalDiagnostics.Field] {
        [
            publicField(Diagnostics.Field.errorCode, errorCode(for: error)),
            publicField(Diagnostics.Field.errorCategory, errorCategory(for: error)),
            privateField(Diagnostics.Field.errorMessage, (error as NSError).localizedDescription)
        ]
    }

    static func errorCode(for error: Swift.Error) -> String {
        switch error {
        case OpalHedgeStartingPriceProofError.invalidSignature,
             OpalHedgeSettlementOracleProofError.invalidSignature:
            return Diagnostics.ErrorCode.oracleInvalidSignature
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
            return Diagnostics.ErrorCode.fundingAlreadyExists
        case let error as OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError:
            return fundingRecordErrorCode(for: error)
        case let error as OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError:
            return settlementRecordErrorCode(for: error)
        case is OpalHedgeCoreSettlementConditionError:
            return Diagnostics.ErrorCode.settlementConditionInvalid
        case is OpalHedgeCoreSettlementCalculationError:
            return Diagnostics.ErrorCode.settlementPayoutInvalid
        default:
            return Diagnostics.ErrorCode.unknown
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

    private static func oracleErrorCode(
        for error: OpalHedgeOracleMessageError
    ) -> String {
        switch error {
        case .invalidHexLength:
            return Diagnostics.ErrorCode.oracleInvalidHexLength
        case .invalidHexCharacter:
            return Diagnostics.ErrorCode.oracleInvalidHexCharacter
        case .invalidMessageLength:
            return Diagnostics.ErrorCode.oracleInvalidMessageLength
        case .invalidScriptInteger:
            return Diagnostics.ErrorCode.oracleInvalidScriptInteger
        case .invalidPrice:
            return Diagnostics.ErrorCode.oracleInvalidPrice
        }
    }

    private static func oracleSignatureErrorCode(
        for error: OpalHedgeOracleSignatureVerificationError
    ) -> String {
        switch error {
        case .invalidPublicKey:
            return Diagnostics.ErrorCode.oracleInvalidPublicKey
        case .invalidSignature:
            return Diagnostics.ErrorCode.oracleInvalidSignature
        case .invalidDigest:
            return Diagnostics.ErrorCode.oracleInvalidDigest
        case .cryptographyFailure:
            return Diagnostics.ErrorCode.oracleCryptographyFailure
        }
    }

    private static func coreConstraintErrorCode(
        for error: OpalHedgeCoreContractConstraintError
    ) -> String {
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
            return Diagnostics.ErrorCode.contractConstraintValidationFailed
        }
    }

    private static func coreDataDocumentErrorCode(
        for error: OpalHedgeCoreContractDataDocumentError
    ) -> String {
        switch error {
        case .invalidJson:
            return Diagnostics.ErrorCode.dataDocumentInvalidJson
        case .invalidRootObject:
            return Diagnostics.ErrorCode.dataDocumentInvalidRootObject
        case .missingField:
            return Diagnostics.ErrorCode.dataDocumentMissingField
        case .invalidFieldType:
            return Diagnostics.ErrorCode.dataDocumentInvalidFieldType
        case .invalidContractSide:
            return Diagnostics.ErrorCode.dataDocumentInvalidContractSide
        case .invalidSettlementType:
            return Diagnostics.ErrorCode.dataDocumentInvalidSettlementType
        }
    }

    private static func bitcoinCashContractAddressErrorCode(
        for error: OpalHedgeBitcoinCashContractAddressError
    ) -> String {
        switch error {
        case .invalidRedeemScriptHex:
            return Diagnostics.ErrorCode.bitcoinCashInvalidRedeemScriptHex
        case .invalidScriptHashByteCount:
            return Diagnostics.ErrorCode.bitcoinCashInvalidScriptHashByteCount
        }
    }

    private static func bitcoinCashScriptEncodingErrorCode(
        for error: OpalHedgeBitcoinCashScriptEncodingError
    ) -> String {
        switch error {
        case .dataPushTooLarge:
            return Diagnostics.ErrorCode.bitcoinCashScriptDataPushTooLarge
        }
    }

    private static func bitcoinCashParameterErrorCode(
        for error: OpalHedgeBitcoinCashAnyHedgeContractParameterError
    ) -> String {
        switch error {
        case .invalidHex:
            return Diagnostics.ErrorCode.bitcoinCashParameterInvalidHex
        case .invalidCompressedPublicKey:
            return Diagnostics.ErrorCode.bitcoinCashParameterInvalidCompressedPublicKey
        case .invalidLockScript:
            return Diagnostics.ErrorCode.bitcoinCashParameterInvalidLockScript
        case .invalidPositiveInteger:
            return Diagnostics.ErrorCode.bitcoinCashParameterInvalidPositiveInteger
        case .invalidNonnegativeInteger:
            return Diagnostics.ErrorCode.bitcoinCashParameterInvalidNonnegativeInteger
        case .invalidBooleanInteger:
            return Diagnostics.ErrorCode.bitcoinCashParameterInvalidBooleanInteger
        }
    }

    private static func fundingRecordErrorCode(
        for error: OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
    ) -> String {
        switch error {
        case .invalidFundingTransactionHash:
            return Diagnostics.ErrorCode.transactionHashInvalid
        case .missingFundingRecord,
             .fundingAlreadySettled,
             .invalidFundingOutputIndex,
             .inconsistentFundingSatoshis:
            return Diagnostics.ErrorCode.fundingRecordInvalid
        }
    }

    private static func settlementRecordErrorCode(
        for error: OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError
    ) -> String {
        switch error {
        case .invalidSettlementTransactionHash:
            return Diagnostics.ErrorCode.transactionHashInvalid
        case .missingFundingRecord,
             .missingDataDocumentFunding,
             .missingSettlement,
             .missingSettlementField,
             .inconsistentSettlement:
            return Diagnostics.ErrorCode.settlementRecordInvalid
        }
    }
}
