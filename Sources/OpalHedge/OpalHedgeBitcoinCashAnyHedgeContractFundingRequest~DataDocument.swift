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
    }

    package static func validateNoExistingFundings(
        _ fundings: [OpalHedgeCoreContractFunding]
    ) throws {
        guard fundings.isEmpty else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingRequestError
                .contractAlreadyFunded(fundingCount: fundings.count)
        }
    }
}
