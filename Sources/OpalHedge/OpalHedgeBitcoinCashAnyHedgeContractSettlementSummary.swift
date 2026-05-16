// OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary.swift

import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary: Sendable, Equatable {
    public let settlementKind: OpalHedgeCoreSettlementKind
    public let fundingTransactionHash: String
    public let fundingOutputIndex: Int64
    public let fundingSatoshis: Int64
    public let settlementTransactionHash: String
    public let settlementPrice: Int64
    public let settlementPayoutAmounts: OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmounts
    public let minerFeeInSatoshis: Int64
    public let dataDocument: OpalHedgeCoreContractDataDocument
    public let previousOracleMessageHex: String
    public let previousOracleSignatureHex: String
    public let previousOracleMessageTimestamp: Int64
    public let previousOracleMessageSequence: Int64
    public let settlementOracleMessageHex: String
    public let settlementOracleSignatureHex: String
    public let settlementOracleMessageTimestamp: Int64
    public let settlementOracleMessageSequence: Int64

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
        self.fundingTransactionHash = funding.fundingTransactionHash
        self.fundingOutputIndex = funding.fundingOutputIndex
        self.fundingSatoshis = funding.fundingSatoshis
        self.settlementTransactionHash = settlementRecord.settlementTransactionHash
        self.settlementPrice = settlementRequest.settlementPrice
        self.settlementPayoutAmounts = settlementRequest.settlementPayoutAmounts
        self.minerFeeInSatoshis = settlementRequest.minerFeeInSatoshis
        self.dataDocument = settlementRecord.dataDocument
        self.previousOracleMessageHex = settlementRequest.previousOracleProof.messageHex
        self.previousOracleSignatureHex = settlementRequest.previousOracleProof.signatureHex
        self.previousOracleMessageTimestamp = settlementRequest.previousOracleProof
            .messageTimestamp
        self.previousOracleMessageSequence = settlementRequest.previousOracleProof
            .messageSequence
        self.settlementOracleMessageHex = settlementRequest.settlementOracleProof.messageHex
        self.settlementOracleSignatureHex = settlementRequest.settlementOracleProof.signatureHex
        self.settlementOracleMessageTimestamp = settlementRequest.settlementOracleProof
            .messageTimestamp
        self.settlementOracleMessageSequence = settlementRequest.settlementOracleProof
            .messageSequence
        OpalHedgeDiagnostics.record(
            OpalHedgeDiagnostics.Event.settlementSummaryCreated,
            category: OpalHedgeDiagnostics.Category.settlement,
            fields: [
                OpalHedgeDiagnostics.operationField("create_settlement_summary"),
                OpalHedgeDiagnostics.moduleField("opalhedge"),
                OpalHedgeDiagnostics.settlementKindField(settlementRecord.settlement.kind),
                OpalHedgeDiagnostics.publicField(
                    OpalHedge.Diagnostics.Field.fundingIndex,
                    settlementRecord.fundingRecord.fundingIndex
                ),
                OpalHedgeDiagnostics.publicField(
                    OpalHedge.Diagnostics.Field.settlementPrice,
                    settlementRequest.settlementPrice
                ),
                OpalHedgeDiagnostics.publicField(
                    OpalHedge.Diagnostics.Field.satoshiCount,
                    settlementPayoutAmounts.totalPayoutInSatoshis
                )
            ]
        )
    }
}
