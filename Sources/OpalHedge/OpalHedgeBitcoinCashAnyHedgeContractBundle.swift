// OpalHedgeBitcoinCashAnyHedgeContractBundle.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore
import OpalDiagnostics

package struct OpalHedgeBitcoinCashAnyHedgeContractBundle: Sendable, Equatable {
    package let plan: OpalHedgeCoreContractPlan
    package let draftData: OpalHedgeCoreContractDraftData
    package let parameterData: OpalHedgeBitcoinCashAnyHedgeContractParameterData
    package let bytecode: OpalHedgeBitcoinCashAnyHedgeContractBytecode
    package let contractAddress: OpalHedgeBitcoinCashContractAddress
    package let fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput
    package let dataDocument: OpalHedgeCoreContractDataDocument
    package let fundingRequest: OpalHedgeBitcoinCashAnyHedgeContractFundingRequest

    package var fundingState: OpalHedgeBitcoinCashAnyHedgeContractFundingState {
        OpalHedgeBitcoinCashAnyHedgeContractFundingState(bundle: self)
    }

    package var lifecycleState: OpalHedgeBitcoinCashAnyHedgeContractLifecycleState {
        OpalHedgeBitcoinCashAnyHedgeContractLifecycleState(bundle: self)
    }

    package func createFundingRecord(
        fundingTransactionHash: String,
        fundingOutputIndex: Int64,
        fundingSatoshis: Int64? = nil
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractFundingRecord {
        try OpalHedgeBitcoinCashAnyHedgeContractFundingRecord(
            bundle: self,
            fundingTransactionHash: fundingTransactionHash,
            fundingOutputIndex: fundingOutputIndex,
            fundingSatoshis: fundingSatoshis
        )
    }

    package init(
        plan: OpalHedgeCoreContractPlan,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws {
        do {
            let draftData = OpalHedgeCoreContractDraftData(
                plan: plan,
                fundings: fundings,
                fees: fees
            )
            try network.validatePayoutAddressNetworks(in: draftData)

            let parameterData = try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
                from: plan
            )
            let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
                parameters: parameterData,
                scriptBytecode: scriptBytecode
            )

            let contractAddress = try bytecode.deriveContractAddress(network: network)
            let fundingOutput = try OpalHedgeBitcoinCashAnyHedgeContractFundingOutput(
                contractAddress: contractAddress,
                payoutSatoshis: plan.parameters.payoutSats,
                dustReserveSatoshis: OpalHedgeCoreContractConstraintPolicy
                    .dustLimitSatoshis
            )
            let dataDocument = try OpalHedgeCoreContractDataDocument(
                draftData: draftData
            )
            let fundingRequest = OpalHedgeBitcoinCashAnyHedgeContractFundingRequest(
                fundingOutput: fundingOutput,
                domainDataDocument: dataDocument,
                rawRedeemScriptBytecode: bytecode.rawRedeemScriptBytecode,
                contractScriptArtifact: bytecode.artifact
            )

            self.plan = plan
            self.draftData = draftData
            self.parameterData = parameterData
            self.bytecode = bytecode
            self.contractAddress = contractAddress
            self.fundingOutput = fundingOutput
            self.dataDocument = dataDocument
            self.fundingRequest = fundingRequest
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.funding).record(
                event: OpalDiagnostics.Event.fundingRequestCreated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("create_funding_request"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingCount,
                        fundings.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.feeCount,
                        fees.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.satoshiCount,
                        fundingOutput.satoshis
                    )
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.funding).record(
                event: OpalDiagnostics.Event.fundingRequestCreationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("create_funding_request"),
                    OpalDiagnostics.Field.moduleField("opalhedge"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.fundingCount,
                        fundings.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.feeCount,
                        fees.count
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }
}
