// OpalHedgeBitcoinCashAnyHedgeContractFundingRecord.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractFundingRecord: Sendable, Equatable {
    public let fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput
    public let fundingIndex: Int
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
        do {
            let fundingOutput = bundle.fundingOutput
            let expectedFundingSatoshis = fundingOutput.satoshis
            let actualFundingSatoshis = fundingSatoshis ?? expectedFundingSatoshis

            try Self.validateFundingTransactionHash(fundingTransactionHash)
            try Self.validateFundingOutputIndex(fundingOutputIndex)
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
            let fundingIndex = bundle.draftData.fundings.endIndex
            let draftData = OpalHedgeCoreContractDraftData(
                parameters: bundle.draftData.parameters,
                metadata: bundle.draftData.metadata,
                fundings: bundle.draftData.fundings + [funding],
                fees: bundle.draftData.fees
            )

            self.fundingOutput = fundingOutput
            self.fundingIndex = fundingIndex
            self.funding = funding
            self.draftData = draftData
            self.dataDocument = try OpalHedgeCoreContractDataDocument(
                draftData: draftData
            )
            OpalHedgeDiagnostics.record(
                OpalHedgeDiagnostics.Event.fundingRecordCreated,
                category: OpalHedgeDiagnostics.Category.funding,
                fields: [
                    OpalHedgeDiagnostics.operationField("create_funding_record"),
                    OpalHedgeDiagnostics.moduleField("opalhedge"),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.fundingIndex,
                        fundingIndex
                    ),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.outputIndex,
                        fundingOutputIndex
                    ),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.satoshiCount,
                        actualFundingSatoshis
                    )
                ]
            )
        } catch {
            OpalHedgeDiagnostics.record(
                OpalHedgeDiagnostics.Event.fundingRecordCreationFailed,
                category: OpalHedgeDiagnostics.Category.funding,
                level: .error,
                fields: [
                    OpalHedgeDiagnostics.operationField("create_funding_record"),
                    OpalHedgeDiagnostics.moduleField("opalhedge"),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.outputIndex,
                        fundingOutputIndex
                    )
                ] + OpalHedgeDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    public init(
        dataDocument: OpalHedgeCoreContractDataDocument,
        fundingIndex: Int = 0,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws {
        let draftData = dataDocument.draftData
        do {
            try network.validatePayoutAddressNetworks(in: draftData)
            _ = try OpalHedge.Oracle.verifyStartingPriceProof(
                messageHex: draftData.metadata.startingOracleMessageHex,
                signatureHex: draftData.metadata.startingOracleSignatureHex,
                publicKeyHex: draftData.parameters.oraclePublicKeyHex
            )

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
            try Self.validateFundingOutputIndex(funding.fundingOutputIndex)
            guard funding.fundingSatoshis == fundingOutput.satoshis else {
                throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                    .inconsistentFundingSatoshis(
                        expected: fundingOutput.satoshis,
                        actual: funding.fundingSatoshis
                    )
            }

            self.fundingOutput = fundingOutput
            self.fundingIndex = fundingIndex
            self.funding = funding
            self.draftData = draftData
            self.dataDocument = dataDocument
            OpalHedgeDiagnostics.record(
                OpalHedgeDiagnostics.Event.fundingRecordCreated,
                category: OpalHedgeDiagnostics.Category.funding,
                fields: [
                    OpalHedgeDiagnostics.operationField("reconstruct_funding_record"),
                    OpalHedgeDiagnostics.moduleField("opalhedge"),
                    OpalHedgeDiagnostics.networkField(network),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.fundingIndex,
                        fundingIndex
                    ),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.outputIndex,
                        funding.fundingOutputIndex
                    ),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.satoshiCount,
                        funding.fundingSatoshis
                    )
                ]
            )
        } catch {
            OpalHedgeDiagnostics.record(
                OpalHedgeDiagnostics.Event.fundingRecordCreationFailed,
                category: OpalHedgeDiagnostics.Category.funding,
                level: .error,
                fields: [
                    OpalHedgeDiagnostics.operationField("reconstruct_funding_record"),
                    OpalHedgeDiagnostics.moduleField("opalhedge"),
                    OpalHedgeDiagnostics.networkField(network),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.fundingIndex,
                        fundingIndex
                    )
                ] + OpalHedgeDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func validateFundingTransactionHash(_ value: String) throws {
        guard OpalHedgeBitcoinCashTransactionHashValidator.isValid(value) else {
            let error = OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .invalidFundingTransactionHash(value)
            OpalHedgeDiagnostics.record(
                OpalHedgeDiagnostics.Event.transactionHashValidationFailed,
                category: OpalHedgeDiagnostics.Category.bitcoinCash,
                level: .error,
                fields: [
                    OpalHedgeDiagnostics.operationField("validate_funding_transaction_hash"),
                    OpalHedgeDiagnostics.moduleField("opalhedge")
                ] + OpalHedgeDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func validateFundingOutputIndex(_ value: Int64) throws {
        guard value >= 0,
              value <= Int64(UInt32.max) else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .invalidFundingOutputIndex(value)
        }
    }
}
