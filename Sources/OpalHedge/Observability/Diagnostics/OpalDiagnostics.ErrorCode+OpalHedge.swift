// OpalDiagnostics.ErrorCode+OpalHedge.swift

import OpalDiagnostics

extension OpalDiagnostics.ErrorCode {
    static let unknown = Self(rawValue: "unknown")
    static let oracleInvalidSignature = Self(rawValue: "oracle.invalid_signature")
    static let transactionHashInvalid = Self(rawValue: "bitcoin_cash.transaction_hash.invalid")
    static let fundingAlreadyExists = Self(rawValue: "funding.already_exists")
    static let fundingOutputInvalidPayoutSatoshis = Self(rawValue: "funding.output.invalid_payout_satoshis")
    static let fundingOutputInvalidDustReserveSatoshis = Self(rawValue: "funding.output.invalid_dust_reserve_satoshis")
    static let fundingOutputSatoshisOverflow = Self(rawValue: "funding.output.satoshis_overflow")
    static let fundingRecordInvalid = Self(rawValue: "funding.record_invalid")
    static let settlementConditionInvalid = Self(rawValue: "settlement.condition_invalid")
    static let settlementPayoutInvalid = Self(rawValue: "settlement.payout_invalid")
    static let settlementRecordInvalid = Self(rawValue: "settlement.record_invalid")
}
