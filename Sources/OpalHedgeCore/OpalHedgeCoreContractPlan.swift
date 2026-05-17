// OpalHedgeCoreContractPlan.swift

import OpalDiagnostics

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
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractPlanCreated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("create_contract_plan"),
                    OpalDiagnostics.Field.moduleField("core")
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractPlanCreationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("create_contract_plan"),
                    OpalDiagnostics.Field.moduleField("core")
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
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
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractPlanCreated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("create_contract_plan"),
                    OpalDiagnostics.Field.moduleField("core")
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractPlanCreationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("create_contract_plan"),
                    OpalDiagnostics.Field.moduleField("core")
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }
}
