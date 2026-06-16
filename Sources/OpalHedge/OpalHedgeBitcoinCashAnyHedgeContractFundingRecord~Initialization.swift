// OpalHedgeBitcoinCashAnyHedgeContractFundingRecord~Initialization.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore
import OpalDiagnostics

extension OpalHedgeBitcoinCashAnyHedgeContractFundingRecord {
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
            self.contractScriptArtifact = bundle.bytecode.artifact
            self.fundingIndex = fundingIndex
            self.funding = funding
            self.draftData = draftData
            self.dataDocument = try OpalHedgeCoreContractDataDocument(
                draftData: draftData
            )
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.funding).record(
                event: OpalDiagnostics.Event.fundingRecordCreated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("create_funding_record"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingIndex,
                        fundingIndex
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.outputIndex,
                        fundingOutputIndex
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.satoshiCount,
                        actualFundingSatoshis
                    )
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.funding).record(
                event: OpalDiagnostics.Event.fundingRecordCreationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("create_funding_record"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.outputIndex,
                        fundingOutputIndex
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
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
            self.contractScriptArtifact = bytecode.artifact
            self.fundingIndex = fundingIndex
            self.funding = funding
            self.draftData = draftData
            self.dataDocument = dataDocument
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.funding).record(
                event: OpalDiagnostics.Event.fundingRecordCreated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("reconstruct_funding_record"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingIndex,
                        fundingIndex
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.outputIndex,
                        funding.fundingOutputIndex
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.satoshiCount,
                        funding.fundingSatoshis
                    )
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.funding).record(
                event: OpalDiagnostics.Event.fundingRecordCreationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("reconstruct_funding_record"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingIndex,
                        fundingIndex
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func validateFundingTransactionHash(_ value: String) throws {
        guard OpalHedgeBitcoinCashTransactionHashValidator.isValid(value) else {
            let error = OpalHedgeBitcoinCashAnyHedgeContractFundingRecordError
                .invalidFundingTransactionHash(value)
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.transactionHashValidationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_funding_transaction_hash"),
                    OpalDiagnostics.Field.moduleField("opalhedge")
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
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
