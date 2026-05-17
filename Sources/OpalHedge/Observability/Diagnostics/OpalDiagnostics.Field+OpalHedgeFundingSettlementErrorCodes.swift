// OpalDiagnostics.Field+OpalHedgeFundingSettlementErrorCodes.swift

import OpalDiagnostics

extension OpalDiagnostics.Field {
    static func fundingOutputErrorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError) -> String {
        switch error {
        case .invalidPayoutSatoshis:
            return OpalHedgeDiagnosticErrorCode.fundingOutputInvalidPayoutSatoshis
        case .invalidDustReserveSatoshis:
            return OpalHedgeDiagnosticErrorCode.fundingOutputInvalidDustReserveSatoshis
        case .fundingSatoshisOverflow:
            return OpalHedgeDiagnosticErrorCode.fundingOutputSatoshisOverflow
        }
    }

    static func fundingRecordErrorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError) -> String {
        switch error {
        case .invalidFundingTransactionHash:
            return OpalHedgeDiagnosticErrorCode.transactionHashInvalid
        case .missingFundingRecord,
             .fundingAlreadySettled,
             .invalidFundingOutputIndex,
             .inconsistentFundingSatoshis:
            return OpalHedgeDiagnosticErrorCode.fundingRecordInvalid
        }
    }

    static func settlementRecordErrorCode(for error: OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError) -> String {
        switch error {
        case .invalidSettlementTransactionHash:
            return OpalHedgeDiagnosticErrorCode.transactionHashInvalid
        case .missingFundingRecord,
             .missingDataDocumentFunding,
             .missingSettlement,
             .missingSettlementField,
             .inconsistentSettlement:
            return OpalHedgeDiagnosticErrorCode.settlementRecordInvalid
        }
    }
}
