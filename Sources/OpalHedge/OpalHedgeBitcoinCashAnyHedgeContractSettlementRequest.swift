// OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest.swift

import OpalHedgeCore
import OpalDiagnostics

public struct OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest: Sendable, Equatable {
    public let domainFundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord
    public let previousOracleDomainProof: OpalHedgeCoreContractSettlementOracleProof
    public let settlementOracleDomainProof: OpalHedgeCoreContractSettlementOracleProof
    public let settlementCondition: OpalHedgeCoreSettlementCondition
    public let settlementKind: OpalHedgeCoreSettlementKind
    public let settlementOutcome: OpalHedgeCoreSettlementOutcome
    public let settlementPayoutAmounts: OpalHedgeBitcoinCashAnyHedgeContractSettlementPayoutAmounts

    public var reviewSummary: OpalHedgeBitcoinCashAnyHedgeContractSettlementReviewSummary {
        OpalHedgeBitcoinCashAnyHedgeContractSettlementReviewSummary(settlementRequest: self)
    }

    @available(*, deprecated, renamed: "domainFundingRecord")
    public var fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord {
        domainFundingRecord
    }

    @available(*, deprecated, renamed: "previousOracleDomainProof")
    public var previousOracleProof: OpalHedgeCoreContractSettlementOracleProof {
        previousOracleDomainProof
    }

    @available(*, deprecated, renamed: "settlementOracleDomainProof")
    public var settlementOracleProof: OpalHedgeCoreContractSettlementOracleProof {
        settlementOracleDomainProof
    }

    public var fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput {
        domainFundingRecord.fundingOutput
    }

    public var domainFunding: OpalHedgeCoreContractFunding {
        domainFundingRecord.funding
    }

    @available(*, deprecated, renamed: "domainFunding")
    public var funding: OpalHedgeCoreContractFunding {
        domainFunding
    }

    public var settlementPrice: Int64 {
        settlementOracleDomainProof.priceValue
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
        domainFundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord,
        previousOracleDomainProof: OpalHedgeCoreContractSettlementOracleProof,
        settlementOracleDomainProof: OpalHedgeCoreContractSettlementOracleProof
    ) throws {
        do {
            let parameters = domainFundingRecord.draftData.parameters
            let settlementCondition = try OpalHedgeCoreSettlementConditionResolver.resolve(
                parameters: parameters,
                previousTimestamp: previousOracleDomainProof.messageTimestamp,
                previousSequence: previousOracleDomainProof.messageSequence,
                settlementTimestamp: settlementOracleDomainProof.messageTimestamp,
                settlementSequence: settlementOracleDomainProof.messageSequence,
                settlementPrice: settlementOracleDomainProof.priceValue
            )
            let settlementOutcome = try OpalHedgeCoreSettlementCalculator.calculateOutcome(
                parameters: parameters,
                fundingSatoshis: domainFundingRecord.funding.fundingSatoshis,
                redeemPrice: settlementOracleDomainProof.priceValue
            )

            self.domainFundingRecord = domainFundingRecord
            self.previousOracleDomainProof = previousOracleDomainProof
            self.settlementOracleDomainProof = settlementOracleDomainProof
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
                        domainFundingRecord.fundingIndex
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.settlementPrice,
                        settlementOracleDomainProof.priceValue
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
                        domainFundingRecord.fundingIndex
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.settlementPrice,
                        settlementOracleDomainProof.priceValue
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    @available(*, deprecated, message: "Use init(domainFundingRecord:previousOracleDomainProof:settlementOracleDomainProof:) so funding and oracle proof material is explicit domain data.")
    public init(
        fundingRecord: OpalHedgeBitcoinCashAnyHedgeContractFundingRecord,
        previousOracleProof: OpalHedgeCoreContractSettlementOracleProof,
        settlementOracleProof: OpalHedgeCoreContractSettlementOracleProof
    ) throws {
        try self.init(
            domainFundingRecord: fundingRecord,
            previousOracleDomainProof: previousOracleProof,
            settlementOracleDomainProof: settlementOracleProof
        )
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
