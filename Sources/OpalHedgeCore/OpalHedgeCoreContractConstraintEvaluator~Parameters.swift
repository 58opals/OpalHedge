// OpalHedgeCoreContractConstraintEvaluator~Parameters.swift

extension OpalHedgeCoreContractConstraintEvaluator {
    package static func validateParametersContext(
        _ context: OpalHedgeCoreContractParametersContext
    ) throws {
        _ = try OpalHedgeCoreContractPlanDerivationContext(
            creationContext: context.creationContext,
            fundingAmounts: context.fundingAmounts
        )
    }
}
