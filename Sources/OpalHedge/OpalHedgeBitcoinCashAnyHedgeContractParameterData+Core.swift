// OpalHedgeBitcoinCashAnyHedgeContractParameterData+Core.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

extension OpalHedgeBitcoinCashAnyHedgeContractParameterData {
    public init(from plan: OpalHedgeCoreContractPlan) throws {
        try self.init(from: plan.parameters)
    }

    public init(from parameters: OpalHedgeCoreContractParameters) throws {
        try self.init(
            shortMutualRedeemPublicKeyHex: parameters.shortMutualRedeemPublicKeyHex,
            longMutualRedeemPublicKeyHex: parameters.longMutualRedeemPublicKeyHex,
            enableMutualRedemption: parameters.enableMutualRedemption,
            shortLockScriptHex: parameters.shortLockScriptHex,
            longLockScriptHex: parameters.longLockScriptHex,
            oraclePublicKeyHex: parameters.oraclePublicKeyHex,
            nominalUnitsXSatsPerBch: parameters.nominalUnitsXSatsPerBch,
            satsForNominalUnitsAtHighLiquidation: parameters
                .satsForNominalUnitsAtHighLiquidation,
            payoutSats: parameters.payoutSats,
            lowLiquidationPrice: parameters.lowLiquidationPrice,
            highLiquidationPrice: parameters.highLiquidationPrice,
            startTimestamp: parameters.startTimestamp,
            maturityTimestamp: parameters.maturityTimestamp
        )
    }
}
