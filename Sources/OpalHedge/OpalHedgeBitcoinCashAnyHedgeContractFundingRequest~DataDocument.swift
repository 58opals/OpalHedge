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
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            from: dataDocument.draftData.parameters,
            scriptBytecode: scriptBytecode
        )
        let contractAddress = try bytecode.deriveContractAddress(network: network)
        let fundingOutput = try OpalHedgeBitcoinCashAnyHedgeContractFundingOutput(
            contractAddress: contractAddress,
            payoutSatoshis: dataDocument.draftData.parameters.payoutSats,
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
}
