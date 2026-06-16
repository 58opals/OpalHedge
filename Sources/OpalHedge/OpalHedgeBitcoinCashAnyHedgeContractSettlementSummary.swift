// OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary.swift

import OpalHedgeCore
import OpalDiagnostics

public struct OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary: Sendable, Equatable {
    public let settlementKind: OpalHedgeCoreSettlementKind
    public let rawFundingTransactionHash: String
    public let fundingOutputIndex: Int64
    public let fundingSatoshis: Int64
    public let rawSettlementTransactionHash: String
    public let settlementPrice: Int64
    public let settlementPayoutAmounts: OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmounts
    public let minerFeeInSatoshis: Int64
    public let domainDataDocument: OpalHedgeCoreContractDataDocument
    public let rawPreviousOracleMessageHex: String
    public let rawPreviousOracleSignatureHex: String
    public let previousOracleMessageTimestamp: Int64
    public let previousOracleMessageSequence: Int64
    public let rawSettlementOracleMessageHex: String
    public let rawSettlementOracleSignatureHex: String
    public let settlementOracleMessageTimestamp: Int64
    public let settlementOracleMessageSequence: Int64

    public var reviewSummary: OpalHedgeBitcoinCashAnyHedgeContractSettlementReviewSummary {
        OpalHedgeBitcoinCashAnyHedgeContractSettlementReviewSummary(
            settlementDomainSummary: self
        )
    }

    @available(*, deprecated, renamed: "rawFundingTransactionHash")
    public var fundingTransactionHash: String {
        rawFundingTransactionHash
    }

    @available(*, deprecated, renamed: "rawSettlementTransactionHash")
    public var settlementTransactionHash: String {
        rawSettlementTransactionHash
    }

    @available(*, deprecated, renamed: "domainDataDocument")
    public var dataDocument: OpalHedgeCoreContractDataDocument {
        domainDataDocument
    }

    @available(*, deprecated, renamed: "rawPreviousOracleMessageHex")
    public var previousOracleMessageHex: String {
        rawPreviousOracleMessageHex
    }

    @available(*, deprecated, renamed: "rawPreviousOracleSignatureHex")
    public var previousOracleSignatureHex: String {
        rawPreviousOracleSignatureHex
    }

    @available(*, deprecated, renamed: "rawSettlementOracleMessageHex")
    public var settlementOracleMessageHex: String {
        rawSettlementOracleMessageHex
    }

    @available(*, deprecated, renamed: "rawSettlementOracleSignatureHex")
    public var settlementOracleSignatureHex: String {
        rawSettlementOracleSignatureHex
    }

    public var hedgePayoutInSatoshis: Int64 {
        settlementPayoutAmounts.hedgePayoutInSatoshis
    }

    public var longPayoutInSatoshis: Int64 {
        settlementPayoutAmounts.longPayoutInSatoshis
    }

    public var totalPayoutInSatoshis: Int64 {
        settlementPayoutAmounts.totalPayoutInSatoshis
    }

    public init(settlementRecord: OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord) {
        let settlementRequest = settlementRecord.settlementRequest
        let funding = settlementRecord.funding

        self.settlementKind = settlementRecord.settlement.kind
        self.rawFundingTransactionHash = funding.fundingTransactionHash
        self.fundingOutputIndex = funding.fundingOutputIndex
        self.fundingSatoshis = funding.fundingSatoshis
        self.rawSettlementTransactionHash = settlementRecord.settlementTransactionHash
        self.settlementPrice = settlementRequest.settlementPrice
        self.settlementPayoutAmounts = settlementRequest.settlementPayoutAmounts
        self.minerFeeInSatoshis = settlementRequest.minerFeeInSatoshis
        self.domainDataDocument = settlementRecord.dataDocument
        self.rawPreviousOracleMessageHex = settlementRequest.previousOracleDomainProof.messageHex
        self.rawPreviousOracleSignatureHex = settlementRequest.previousOracleDomainProof.signatureHex
        self.previousOracleMessageTimestamp = settlementRequest.previousOracleDomainProof
            .messageTimestamp
        self.previousOracleMessageSequence = settlementRequest.previousOracleDomainProof
            .messageSequence
        self.rawSettlementOracleMessageHex = settlementRequest.settlementOracleDomainProof.messageHex
        self.rawSettlementOracleSignatureHex = settlementRequest.settlementOracleDomainProof.signatureHex
        self.settlementOracleMessageTimestamp = settlementRequest.settlementOracleDomainProof
            .messageTimestamp
        self.settlementOracleMessageSequence = settlementRequest.settlementOracleDomainProof
            .messageSequence
        OpalDiagnostics.logger(category: OpalDiagnostics.Category.settlement).record(
            event: OpalDiagnostics.Event.settlementSummaryCreated,
            level: .debug,
            fields: [
                OpalDiagnostics.Field.operationField("create_settlement_summary"),
                OpalDiagnostics.Field.moduleField("opalhedge"),
                OpalDiagnostics.Field.settlementKindField(settlementRecord.settlement.kind),
                OpalDiagnostics.Field.publicField(
                    OpalDiagnostics.Field.fundingIndex,
                    settlementRecord.fundingRecord.fundingIndex
                ),
                OpalDiagnostics.Field.publicField(
                    OpalDiagnostics.Field.settlementPrice,
                    settlementRequest.settlementPrice
                ),
                OpalDiagnostics.Field.publicField(
                    OpalDiagnostics.Field.satoshiCount,
                    settlementPayoutAmounts.totalPayoutInSatoshis
                )
            ]
        )
    }
}

extension OpalHedgeBitcoinCashAnyHedgeContractSettlementReviewSummary {
    public init(
        settlementDomainSummary: OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary
    ) {
        self.settlementKind = settlementDomainSummary.settlementKind
        self.fundingOutputIndex = settlementDomainSummary.fundingOutputIndex
        self.fundingSatoshis = settlementDomainSummary.fundingSatoshis
        self.settlementPrice = settlementDomainSummary.settlementPrice
        self.settlementPayoutAmounts = settlementDomainSummary.settlementPayoutAmounts
        self.minerFeeInSatoshis = settlementDomainSummary.minerFeeInSatoshis
        self.previousOracleMessageTimestamp = settlementDomainSummary
            .previousOracleMessageTimestamp
        self.previousOracleMessageSequence = settlementDomainSummary
            .previousOracleMessageSequence
        self.settlementOracleMessageTimestamp = settlementDomainSummary
            .settlementOracleMessageTimestamp
        self.settlementOracleMessageSequence = settlementDomainSummary
            .settlementOracleMessageSequence
    }
}
