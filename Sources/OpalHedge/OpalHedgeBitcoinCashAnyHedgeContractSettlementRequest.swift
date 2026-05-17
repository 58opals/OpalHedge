// OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest.swift

import OpalHedgeCore
import OpalDiagnostics

public struct OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest: Sendable, Equatable {
    public let fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord
    public let previousOracleProof: OpalHedgeCoreContractSettlementOracleProof
    public let settlementOracleProof: OpalHedgeCoreContractSettlementOracleProof
    public let settlementCondition: OpalHedgeCoreSettlementCondition
    public let settlementKind: OpalHedgeCoreSettlementKind
    public let settlementOutcome: OpalHedgeCoreSettlementOutcome
    public let settlementPayoutAmounts: OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmounts

    public var fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput {
        fundingRecord.fundingOutput
    }

    public var funding: OpalHedgeCoreContractFunding {
        fundingRecord.funding
    }

    public var settlementPrice: Int64 {
        settlementOracleProof.priceValue
    }

    public var hedgePayoutInSatoshis: Int64 {
        settlementPayoutAmounts.hedgePayoutInSatoshis
    }

    public var longPayoutInSatoshis: Int64 {
        settlementPayoutAmounts.longPayoutInSatoshis
    }

    public var minerFeeInSatoshis: Int64 {
        settlementOutcome.minerFeeSats
    }

    public func createSettlementRecord(
        settlementTransactionHash: String
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord {
        try OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord(
            settlementRequest: self,
            settlementTransactionHash: settlementTransactionHash
        )
    }

    public init(
        fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord,
        previousOracleProof: OpalHedgeCoreContractSettlementOracleProof,
        settlementOracleProof: OpalHedgeCoreContractSettlementOracleProof
    ) throws {
        do {
            let parameters = fundingRecord.draftData.parameters
            let settlementCondition = try OpalHedgeCoreSettlementConditionResolver.resolve(
                parameters: parameters,
                previousTimestamp: previousOracleProof.messageTimestamp,
                previousSequence: previousOracleProof.messageSequence,
                settlementTimestamp: settlementOracleProof.messageTimestamp,
                settlementSequence: settlementOracleProof.messageSequence,
                settlementPrice: settlementOracleProof.priceValue
            )
            let settlementOutcome = try OpalHedgeCoreSettlementCalculator.calculateOutcome(
                parameters: parameters,
                fundingSatoshis: fundingRecord.funding.fundingSatoshis,
                redeemPrice: settlementOracleProof.priceValue
            )

            self.fundingRecord = fundingRecord
            self.previousOracleProof = previousOracleProof
            self.settlementOracleProof = settlementOracleProof
            self.settlementCondition = settlementCondition
            self.settlementKind = Self.settlementKind(for: settlementCondition)
            self.settlementOutcome = settlementOutcome
            self.settlementPayoutAmounts =
                OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmounts(
                    settlementOutcome: settlementOutcome
                )
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.settlement).record(
                event: OpalDiagnostics.Event.settlementRequestCreated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("create_settlement_request"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.settlementKindField(self.settlementKind),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingIndex,
                        fundingRecord.fundingIndex
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.settlementPrice,
                        settlementOracleProof.priceValue
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.satoshiCount,
                        settlementOutcome.totalPayoutSatsSafe
                    )
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.settlement).record(
                event: OpalDiagnostics.Event.settlementRequestCreationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("create_settlement_request"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingIndex,
                        fundingRecord.fundingIndex
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.settlementPrice,
                        settlementOracleProof.priceValue
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func settlementKind(
        for condition: OpalHedgeCoreSettlementCondition
    ) -> OpalHedgeCoreSettlementKind {
        switch condition {
        case .maturation:
            .maturation
        case .liquidation:
            .liquidation
        }
    }
}
