// OpalHedgeCoreContractPlanDerivationContext.swift

public struct OpalHedgeCoreContractPlanDerivationContext: Sendable, Equatable {
    public let creationContext: OpalHedgeCoreContractCreationContext
    public let fundingAmounts: OpalHedgeCoreContractFundingAmounts

    public init(creationContext: OpalHedgeCoreContractCreationContext) throws {
        self.creationContext = creationContext
        self.fundingAmounts = try OpalHedgeCoreContractFundingAmounts(from: creationContext)
    }

    public init(
        creationContext: OpalHedgeCoreContractCreationContext,
        fundingAmounts: OpalHedgeCoreContractFundingAmounts
    ) throws {
        self.creationContext = creationContext
        self.fundingAmounts = fundingAmounts
        try OpalHedgeCoreContractConstraintEvaluator.validatePlanDerivationContext(self)
    }
}
