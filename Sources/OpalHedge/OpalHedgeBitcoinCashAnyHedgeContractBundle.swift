// OpalHedgeBitcoinCashAnyHedgeContractBundle.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractBundle: Sendable, Equatable {
    public let plan: OpalHedgeCoreContractPlan
    public let draftData: OpalHedgeCoreContractDraftData
    public let parameterData: OpalHedgeBitcoinCashAnyHedgeContractParameterData
    public let bytecode: OpalHedgeBitcoinCashAnyHedgeContractBytecode
    public let contractAddress: OpalHedgeBitcoinCashContractAddress
    public let fundingOutput: OpalHedgeBitcoinCashAnyHedgeContractFundingOutput
    public let dataDocument: OpalHedgeCoreContractDataDocument
    public let fundingRequest: OpalHedgeBitcoinCashAnyHedgeContractFundingRequest

    public var fundingState: OpalHedgeBitcoinCashAnyHedgeContractFundingState {
        OpalHedgeBitcoinCashAnyHedgeContractFundingState(bundle: self)
    }

    public var lifecycleState: OpalHedgeBitcoinCashAnyHedgeContractLifecycleState {
        OpalHedgeBitcoinCashAnyHedgeContractLifecycleState(bundle: self)
    }

    public func createFundingRecord(
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

    public init(
        plan: OpalHedgeCoreContractPlan,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) throws {
        let draftData = OpalHedgeCoreContractDraftData(
            plan: plan,
            fundings: fundings,
            fees: fees
        )
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
            contractDataDocument: dataDocument,
            redeemScriptBytecode: bytecode.redeemScriptBytecode,
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
    }
}
