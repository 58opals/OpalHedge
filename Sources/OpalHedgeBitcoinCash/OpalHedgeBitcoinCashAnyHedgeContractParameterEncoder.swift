// OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder.swift

import Foundation

public enum OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder {
    public static func encodeConstructorStackPushes(
        from parameters: OpalHedgeBitcoinCashAnyHedgeContractParameterData
    ) throws -> [Data] {
        [
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeScriptNumberPush(parameters.maturityTimestamp),
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeScriptNumberPush(parameters.startTimestamp),
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeScriptNumberPush(parameters.highLiquidationPrice),
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeScriptNumberPush(parameters.lowLiquidationPrice),
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeScriptNumberPush(parameters.payoutSats),
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeScriptNumberPush(parameters.satsForNominalUnitsAtHighLiquidation),
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeScriptNumberPush(parameters.nominalUnitsXSatsPerBch),
            try OpalHedgeBitcoinCashScriptEncoder.encodeDataPush(parameters.oraclePublicKey),
            try OpalHedgeBitcoinCashScriptEncoder.encodeDataPush(parameters.longLockScript),
            try OpalHedgeBitcoinCashScriptEncoder.encodeDataPush(parameters.shortLockScript),
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeScriptNumberPush(parameters.enableMutualRedemption),
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeDataPush(parameters.longMutualRedeemPublicKey),
            try OpalHedgeBitcoinCashScriptEncoder
                .encodeDataPush(parameters.shortMutualRedeemPublicKey)
        ]
    }

    public static func encodeConstructorStackBytecode(
        from parameters: OpalHedgeBitcoinCashAnyHedgeContractParameterData
    ) throws -> Data {
        let pushes = try encodeConstructorStackPushes(from: parameters)
        var bytecode = Data()
        bytecode.reserveCapacity(pushes.reduce(0) { $0 + $1.count })

        for push in pushes {
            bytecode.append(push)
        }

        return bytecode
    }
}
