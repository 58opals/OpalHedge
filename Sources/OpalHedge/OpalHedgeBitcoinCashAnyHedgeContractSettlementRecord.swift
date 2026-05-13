// OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord.swift

import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord: Sendable, Equatable {
    public let settlementRequest: OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest
    public let settlement: OpalHedgeCoreContractSettlement
    public let funding: OpalHedgeCoreContractFunding
    public let draftData: OpalHedgeCoreContractDraftData
    public let dataDocument: OpalHedgeCoreContractDataDocument

    public var fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord {
        settlementRequest.fundingRecord
    }

    public var settlementTransactionHash: String {
        settlement.settlementTransactionHash
    }

    public var lifecycleState: OpalHedgeBitcoinCashAnyHedgeContractLifecycleState {
        OpalHedgeBitcoinCashAnyHedgeContractLifecycleState(settlementRecord: self)
    }

    public var settlementSummary: OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary {
        OpalHedgeBitcoinCashAnyHedgeContractSettlementSummary(settlementRecord: self)
    }

    public init(
        settlementRequest: OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest,
        settlementTransactionHash: String
    ) throws {
        try Self.validateSettlementTransactionHash(settlementTransactionHash)

        let settlement = OpalHedgeCoreContractSettlement(
            kind: settlementRequest.settlementKind,
            settlementTransactionHash: settlementTransactionHash,
            payoutAmounts: OpalHedgeCoreContractSettlementPayoutAmounts(
                shortPayoutInSatoshis: settlementRequest.hedgePayoutInSatoshis,
                longPayoutInSatoshis: settlementRequest.longPayoutInSatoshis
            ),
            settlementMessageHex: settlementRequest.settlementOracleProof.messageHex,
            settlementSignatureHex: settlementRequest.settlementOracleProof.signatureHex,
            previousMessageHex: settlementRequest.previousOracleProof.messageHex,
            previousSignatureHex: settlementRequest.previousOracleProof.signatureHex,
            settlementPrice: settlementRequest.settlementPrice
        )
        let fundingRecord = settlementRequest.fundingRecord
        let funding = OpalHedgeCoreContractFunding(
            fundingTransactionHash: fundingRecord.funding.fundingTransactionHash,
            fundingOutputIndex: fundingRecord.funding.fundingOutputIndex,
            fundingSatoshis: fundingRecord.funding.fundingSatoshis,
            settlement: settlement
        )
        var fundings = fundingRecord.draftData.fundings
        let fundingIndex = fundingRecord.fundingIndex
        guard fundings.indices.contains(fundingIndex),
              fundings[fundingIndex] == fundingRecord.funding else {
            throw OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError
                .missingFundingRecord
        }
        fundings[fundingIndex] = funding

        let draftData = OpalHedgeCoreContractDraftData(
            parameters: fundingRecord.draftData.parameters,
            metadata: fundingRecord.draftData.metadata,
            fundings: fundings,
            fees: fundingRecord.draftData.fees
        )

        self.settlementRequest = settlementRequest
        self.settlement = settlement
        self.funding = funding
        self.draftData = draftData
        self.dataDocument = try OpalHedgeCoreContractDataDocument(
            draftData: draftData
        )
    }

    private static func validateSettlementTransactionHash(_ value: String) throws {
        guard OpalHedgeBitcoinCashTransactionHashValidator.isValid(value) else {
            throw OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError
                .invalidSettlementTransactionHash(value)
        }
    }
}
