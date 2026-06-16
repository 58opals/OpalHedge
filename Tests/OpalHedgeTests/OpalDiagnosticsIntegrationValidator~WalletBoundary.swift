// OpalDiagnosticsIntegrationValidator~WalletBoundary.swift

import OpalDiagnostics
import OpalHedge
import OpalHedgeBitcoinCash
import Testing

extension OpalDiagnosticsIntegrationValidator {
    @Test("Diagnostics do not retain raw wallet boundary material")
    func diagnosticsDoNotRetainRawWalletBoundaryMaterial() throws {
        try withDiagnosticsCapture {
            let clientContext = OpalHedge.Client.Context()
            let plan = try OpalHedge.Core.ContractPlan(
                from: OpalHedgeContractFixtureBuilder.makeVerifiedCreationContext()
            )
            let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
                from: plan
            )
            let fundingRequest = try clientContext.createAnyHedgeContractFundingRequest(
                from: plan
            )
            let fundingTransactionHash = String(repeating: "1", count: 64)
            let settlementTransactionHash = String(repeating: "2", count: 64)
            let settlementRecord = try clientContext.createAnyHedgeContractSettlementRecord(
                from: plan,
                fundingTransactionHash: fundingTransactionHash,
                fundingOutputIndex: 0,
                previousOracleProof: OpalHedgeContractFixtureBuilder
                    .makeVerifiedStartingSettlementOracleProof(),
                settlementOracleProof: OpalHedgeContractFixtureBuilder
                    .makeVerifiedSettlementOracleProof(),
                settlementTransactionHash: settlementTransactionHash
            )
            _ = try bytecode.deriveContractAddress(network: .mainnet)
            #expect(settlementRecord.settlement.settlementPrice == 23_500)

            let forbiddenValues = [
                OpalHedgeFixtureData.startingOracleMessageHex,
                OpalHedgeFixtureData.startingOracleSignatureHex,
                OpalHedgeFixtureData.oraclePublicKeyHex,
                fundingTransactionHash,
                settlementTransactionHash,
                fundingRequest.fundingOutput.contractAddress.rawValue,
                rawRedeemScriptHexText(from: bytecode)
            ]

            for record in OpalDiagnostics.recentRecords {
                #expect(forbiddenRawDiagnosticFieldNames(in: record).isEmpty)
                #expect(!containsForbiddenRawDiagnosticValue(
                    in: record,
                    forbiddenValues: forbiddenValues
                ))
            }
        }
    }
}
