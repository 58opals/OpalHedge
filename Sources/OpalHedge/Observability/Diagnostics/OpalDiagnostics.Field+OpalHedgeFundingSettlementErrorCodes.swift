// OpalDiagnostics.Field+OpalHedgeFundingSettlementErrorCodes.swift

import OpalDiagnostics

extension OpalDiagnostics.Field {
    static func fundingOutputErrorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .invalidPayoutSatoshis:
            return OpalDiagnostics.ErrorCode.fundingOutputInvalidPayoutSatoshis
        case .invalidDustReserveSatoshis:
            return OpalDiagnostics.ErrorCode.fundingOutputInvalidDustReserveSatoshis
        case .fundingSatoshisOverflow:
            return OpalDiagnostics.ErrorCode.fundingOutputSatoshisOverflow
        }
    }

    static func fundingRecordErrorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .invalidFundingTransactionHash:
            return OpalDiagnostics.ErrorCode.transactionHashInvalid
        case .missingFundingRecord,
             .fundingAlreadySettled,
             .invalidFundingOutputIndex,
             .inconsistentFundingSatoshis:
            return OpalDiagnostics.ErrorCode.fundingRecordInvalid
        }
    }

    static func settlementRecordErrorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError) -> OpalDiagnostics.ErrorCode {
        switch error {
        case .invalidSettlementTransactionHash:
            return OpalDiagnostics.ErrorCode.transactionHashInvalid
        case .missingFundingRecord,
             .missingDataDocumentFunding,
             .missingSettlement,
             .missingSettlementField,
             .inconsistentSettlement:
            return OpalDiagnostics.ErrorCode.settlementRecordInvalid
        }
    }
}
