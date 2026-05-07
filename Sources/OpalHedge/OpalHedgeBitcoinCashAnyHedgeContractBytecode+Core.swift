// OpalHedgeBitcoinCashAnyHedgeContractBytecode+Core.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

extension OpalHedgeBitcoinCashAnyHedgeContractBytecode {
    public init(
        from plan: OpalHedgeCoreContractPlan,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws {
        try self.init(
            parameters: OpalHedgeBitcoinCashAnyHedgeContractParameterData(from: plan),
            scriptBytecode: scriptBytecode
        )
    }

    public init(
        from parameters: OpalHedgeCoreContractParameters,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws {
        try self.init(
            parameters: OpalHedgeBitcoinCashAnyHedgeContractParameterData(
                from: parameters
            ),
            scriptBytecode: scriptBytecode
        )
    }
}
