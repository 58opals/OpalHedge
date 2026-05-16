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
        do {
            let derivationContext = try OpalHedgeCoreContractPlanDerivationContext(
                creationContext: context
            )
            let parameters = try OpalHedgeCoreContractParameters(
                from: derivationContext
            )
            let metadata = try OpalHedgeCoreContractMetadata(
                from: derivationContext
            )

            self.parameters = parameters
            self.metadata = metadata
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractPlanCreated,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("create_contract_plan"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ]
            )
        } catch {
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractPlanCreationFailed,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("create_contract_plan"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ] + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    public init(from context: OpalHedgeCoreContractPlanDerivationContext) throws {
        do {
            let parameters = try OpalHedgeCoreContractParameters(
                from: context
            )
            let metadata = try OpalHedgeCoreContractMetadata(
                from: context
            )

            self.parameters = parameters
            self.metadata = metadata
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractPlanCreated,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("create_contract_plan"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ]
            )
        } catch {
            OpalHedgeCoreDiagnostics.record(
                OpalHedgeCoreDiagnostics.Event.contractPlanCreationFailed,
                category: OpalHedgeCoreDiagnostics.Category.contract,
                level: .error,
                fields: [
                    OpalHedgeCoreDiagnostics.operationField("create_contract_plan"),
                    OpalHedgeCoreDiagnostics.moduleField("core")
                ] + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }
}
