// OpalHedgeCoreContractPlanner.swift

public enum OpalHedgeCoreContractPlanner {
    /// Derives AnyHedge v0.12 contract parameters and metadata from verified starting conditions.
    public static func createPlan(
        from context: OpalHedgeCoreContractCreationContext
    ) throws -> OpalHedgeCoreContractPlan {
        try OpalHedgeCoreContractPlan(from: context)
    }
}
