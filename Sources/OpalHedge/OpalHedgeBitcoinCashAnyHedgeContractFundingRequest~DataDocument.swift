// OpalHedgeBitcoinCashAnyHedgeContractFundingRequest~DataDocument.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore
import OpalDiagnostics

extension OpalHedgeBitcoinCashAnyHedgeContractFundingRequest {
    public init(
        dataDocument: OpalHedgeCoreContractDataDocument,
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
            try Self.validateNoExistingFundings(draftData.fundings)

            let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
                from: draftData.parameters,
                scriptBytecode: scriptBytecode
            )
            let contractAddress = try bytecode.deriveContractAddress(network: network)
            let fundingOutput = try OpalHedgeBitcoinCashAnyHedgeContractFundingOutput(
                contractAddress: contractAddress,
                payoutSatoshis: draftData.parameters.payoutSats,
                dustReserveSatoshis: OpalHedgeCoreContractConstraintPolicy
                    .dustLimitSatoshis
            )

            self.init(
                fundingOutput: fundingOutput,
                domainDataDocument: dataDocument,
                rawRedeemScriptBytecode: bytecode.rawRedeemScriptBytecode,
                contractScriptArtifact: bytecode.artifact
            )
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.funding).record(
                event: OpalDiagnostics.Event.fundingRequestCreated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("reconstruct_funding_request"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingCount,
                        draftData.fundings.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.feeCount,
                        draftData.fees.count
                    )
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.funding).record(
                event: OpalDiagnostics.Event.fundingRequestCreationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("reconstruct_funding_request"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingCount,
                        draftData.fundings.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.feeCount,
                        draftData.fees.count
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    package static func validateNoExistingFundings(
        _ fundings: [OpalHedgeCoreContractFunding]
    ) throws {
        guard fundings.isEmpty else {
            let error = OpalHedgeBitcoinCashAnyHedgeContractFundingRequestError
                .contractAlreadyFunded(fundingCount: fundings.count)
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.funding).record(
                event: OpalDiagnostics.Event.fundingRequestCreationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_no_existing_fundings"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingCount,
                        fundings.count
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }
}
