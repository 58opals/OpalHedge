// OpalHedgeCoreContractPlan.swift

public struct OpalHedgeCoreContractPlan: Sendable, Equatable {
    public let parameters: OpalHedgeCoreContractParameters
    public let metadata: OpalHedgeCoreContractMetadata

    public init(
        parameters: OpalHedgeCoreContractParameters,
        metadata: OpalHedgeCoreContractMetadata
    ) {
        self.parameters = parameters
        self.metadata = metadata
    }

    public init(from context: OpalHedgeCoreContractCreationContext) throws {
        try self.init(
            from: OpalHedgeCoreContractPlanDerivationContext(
                creationContext: context
            )
        )
    }

    public init(from context: OpalHedgeCoreContractPlanDerivationContext) throws {
        let parameters = try OpalHedgeCoreContractParameters(
            from: context
        )
        let metadata = try OpalHedgeCoreContractMetadata(
            from: context
        )

        self.init(parameters: parameters, metadata: metadata)
    }
}
