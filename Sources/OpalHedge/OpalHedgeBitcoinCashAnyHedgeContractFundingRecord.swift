// OpalHedgeBitcoinCashAnyHedgeContractFundingRecord.swift

import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractFundingRecord: Sendable, Equatable {
    public let fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput
    public let funding: OpalHedgeCoreContractFunding
    public let draftData: OpalHedgeCoreContractDraftData
    public let dataDocument: OpalHedgeCoreContractDataDocument

    public var fundingState: OpalHedgeBitcoinCashAnyHedgeContractFundingState {
        OpalHedgeBitcoinCashAnyHedgeContractFundingState(fundingRecord: self)
    }

    public var lifecycleState: OpalHedgeBitcoinCashAnyHedgeContractLifecycleState {
        OpalHedgeBitcoinCashAnyHedgeContractLifecycleState(fundingRecord: self)
    }

    public func createSettlementRequest(
        previousOracleProof: OpalHedgeCoreContractSettlementOracleProof,
        settlementOracleProof: OpalHedgeCoreContractSettlementOracleProof
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest {
        try OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest(
            fundingRecord: self,
            previousOracleProof: previousOracleProof,
            settlementOracleProof: settlementOracleProof
        )
    }

    public init(
        bundle: OpalHedgeBitcoinCashAnyHedgeContractBundle,
        fundingTransactionHash: String,
        fundingOutputIndex: Int64,
        fundingSatoshis: Int64? = nil
    ) throws {
        let fundingOutput = bundle.fundingOutput
        let expectedFundingSatoshis = fundingOutput.satoshis
        let actualFundingSatoshis = fundingSatoshis ?? expectedFundingSatoshis

        try Self.validateFundingTransactionHash(fundingTransactionHash)
        guard fundingOutputIndex >= 0 else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .invalidFundingOutputIndex(fundingOutputIndex)
        }
        guard actualFundingSatoshis == expectedFundingSatoshis else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .inconsistentFundingSatoshis(
                    expected: expectedFundingSatoshis,
                    actual: actualFundingSatoshis
                )
        }

        let funding = OpalHedgeCoreContractFunding(
            fundingTransactionHash: fundingTransactionHash,
            fundingOutputIndex: fundingOutputIndex,
            fundingSatoshis: actualFundingSatoshis
        )
        let draftData = OpalHedgeCoreContractDraftData(
            parameters: bundle.draftData.parameters,
            metadata: bundle.draftData.metadata,
            fundings: bundle.draftData.fundings + [funding],
            fees: bundle.draftData.fees
        )

        self.fundingOutput = fundingOutput
        self.funding = funding
        self.draftData = draftData
        self.dataDocument = try OpalHedgeCoreContractDataDocument(
            draftData: draftData
        )
    }

    private static func validateFundingTransactionHash(_ value: String) throws {
        guard value.utf8.count == 64,
              value.utf8.allSatisfy({ byte in
                  (48...57).contains(byte) ||
                      (65...70).contains(byte) ||
                      (97...102).contains(byte)
              }) else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .invalidFundingTransactionHash(value)
        }
    }
}
