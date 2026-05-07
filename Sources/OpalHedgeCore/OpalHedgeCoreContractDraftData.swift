// OpalHedgeCoreContractDraftData.swift

public struct OpalHedgeCoreContractDraftData: Sendable, Equatable {
    public let parameters: OpalHedgeCoreContractParameters
    public let metadata: OpalHedgeCoreContractMetadata
    public let fundings: [OpalHedgeCoreContractFunding]
    public let fees: [OpalHedgeCoreContractFeeData]

    public init(
        parameters: OpalHedgeCoreContractParameters,
        metadata: OpalHedgeCoreContractMetadata,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) {
        self.parameters = parameters
        self.metadata = metadata
        self.fundings = fundings
        self.fees = fees
    }

    public init(
        plan: OpalHedgeCoreContractPlan,
        fundings: [OpalHedgeCoreContractFunding] = [],
        fees: [OpalHedgeCoreContractFeeData] = []
    ) {
        self.init(
            parameters: plan.parameters,
            metadata: plan.metadata,
            fundings: fundings,
            fees: fees
        )
    }
}
