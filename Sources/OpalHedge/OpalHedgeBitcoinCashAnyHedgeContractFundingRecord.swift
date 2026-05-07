// OpalHedgeBitcoinCashAnyHedgeContractFundingRecord.swift

import OpalHedgeBitcoinCash
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

    package init(
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

    public init(
        dataDocument: OpalHedgeCoreContractDataDocument,
        fundingIndex: Int = 0,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws {
        let draftData = dataDocument.draftData
        try network.validatePayoutAddressNetworks(in: draftData)

        guard draftData.fundings.indices.contains(fundingIndex) else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .missingFundingRecord(index: fundingIndex)
        }
        let funding = draftData.fundings[fundingIndex]
        guard funding.settlement == nil else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .fundingAlreadySettled(index: fundingIndex)
        }

        let parameterData = try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
            from: draftData.parameters
        )
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            parameters: parameterData,
            scriptBytecode: scriptBytecode
        )
        let contractAddress = try bytecode.deriveContractAddress(network: network)
        let fundingOutput = try OpalHedgeBitcoinCashAnyHedgeContractFundingOutput(
            contractAddress: contractAddress,
            payoutSatoshis: draftData.parameters.payoutSats,
            dustReserveSatoshis: OpalHedgeCoreContractConstraintPolicy
                .dustLimitSatoshis
        )

        try Self.validateFundingTransactionHash(funding.fundingTransactionHash)
        guard funding.fundingOutputIndex >= 0 else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .invalidFundingOutputIndex(funding.fundingOutputIndex)
        }
        guard funding.fundingSatoshis == fundingOutput.satoshis else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .inconsistentFundingSatoshis(
                    expected: fundingOutput.satoshis,
                    actual: funding.fundingSatoshis
                )
        }

        self.fundingOutput = fundingOutput
        self.funding = funding
        self.draftData = draftData
        self.dataDocument = dataDocument
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
