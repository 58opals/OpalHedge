// OpalHedgeBitcoinCashAnyHedgeContractFundingRequest~DataDocument.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

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
                contractDataDocument: dataDocument,
                redeemScriptBytecode: bytecode.redeemScriptBytecode,
                contractScriptArtifact: bytecode.artifact
            )
            OpalHedgeDiagnostics.record(
                OpalHedgeDiagnostics.Event.fundingRequestCreated,
                category: OpalHedgeDiagnostics.Category.funding,
                fields: [
                    OpalHedgeDiagnostics.operationField("reconstruct_funding_request"),
                    OpalHedgeDiagnostics.moduleField("opalhedge"),
                    OpalHedgeDiagnostics.networkField(network),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.fundingCount,
                        draftData.fundings.count
                    ),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.feeCount,
                        draftData.fees.count
                    )
                ]
            )
        } catch {
            OpalHedgeDiagnostics.record(
                OpalHedgeDiagnostics.Event.fundingRequestCreationFailed,
                category: OpalHedgeDiagnostics.Category.funding,
                level: .error,
                fields: [
                    OpalHedgeDiagnostics.operationField("reconstruct_funding_request"),
                    OpalHedgeDiagnostics.moduleField("opalhedge"),
                    OpalHedgeDiagnostics.networkField(network),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.fundingCount,
                        draftData.fundings.count
                    ),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.feeCount,
                        draftData.fees.count
                    )
                ] + OpalHedgeDiagnostics.makeErrorFields(for: error)
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
            OpalHedgeDiagnostics.record(
                OpalHedgeDiagnostics.Event.fundingRequestCreationFailed,
                category: OpalHedgeDiagnostics.Category.funding,
                level: .error,
                fields: [
                    OpalHedgeDiagnostics.operationField("validate_no_existing_fundings"),
                    OpalHedgeDiagnostics.moduleField("opalhedge"),
                    OpalHedgeDiagnostics.publicField(
                        OpalHedge.Diagnostics.Field.fundingCount,
                        fundings.count
                    )
                ] + OpalHedgeDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }
}
