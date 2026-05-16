// OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder.swift

import Foundation

public enum OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder {
    public static func encodeConstructorStackPushes(
        from parameters: OpalHedgeBitcoinCashAnyHedgeContractParameterData
    ) throws -> [Data] {
        do {
            let pushes = [
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
            OpalHedgeBitcoinCashDiagnostics.record(
                OpalHedgeBitcoinCashDiagnostics.Event.contractParametersEncoded,
                fields: [
                    OpalHedgeBitcoinCashDiagnostics.operationField("encode_constructor_stack_pushes"),
                    OpalHedgeBitcoinCashDiagnostics.moduleField("bitcoin_cash"),
                    OpalHedgeBitcoinCashDiagnostics.publicField(
                        OpalHedgeBitcoinCashDiagnostics.Field.pushCount,
                        pushes.count
                    )
                ]
            )
            return pushes
        } catch {
            OpalHedgeBitcoinCashDiagnostics.record(
                OpalHedgeBitcoinCashDiagnostics.Event.contractParameterEncodingFailed,
                level: .error,
                fields: [
                    OpalHedgeBitcoinCashDiagnostics.operationField("encode_constructor_stack_pushes"),
                    OpalHedgeBitcoinCashDiagnostics.moduleField("bitcoin_cash")
                ] + OpalHedgeBitcoinCashDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    public static func encodeConstructorStackBytecode(
        from parameters: OpalHedgeBitcoinCashAnyHedgeContractParameterData
    ) throws -> Data {
        do {
            let pushes = try encodeConstructorStackPushes(from: parameters)
            var bytecode = Data()
            bytecode.reserveCapacity(pushes.reduce(0) { $0 + $1.count })

            for push in pushes {
                bytecode.append(push)
            }

            OpalHedgeBitcoinCashDiagnostics.record(
                OpalHedgeBitcoinCashDiagnostics.Event.contractParametersEncoded,
                fields: [
                    OpalHedgeBitcoinCashDiagnostics.operationField("encode_constructor_stack_bytecode"),
                    OpalHedgeBitcoinCashDiagnostics.moduleField("bitcoin_cash"),
                    OpalHedgeBitcoinCashDiagnostics.publicField(
                        OpalHedgeBitcoinCashDiagnostics.Field.byteCount,
                        bytecode.count
                    ),
                    OpalHedgeBitcoinCashDiagnostics.publicField(
                        OpalHedgeBitcoinCashDiagnostics.Field.pushCount,
                        pushes.count
                    )
                ]
            )
            return bytecode
        } catch {
            OpalHedgeBitcoinCashDiagnostics.record(
                OpalHedgeBitcoinCashDiagnostics.Event.contractParameterEncodingFailed,
                level: .error,
                fields: [
                    OpalHedgeBitcoinCashDiagnostics.operationField("encode_constructor_stack_bytecode"),
                    OpalHedgeBitcoinCashDiagnostics.moduleField("bitcoin_cash")
                ] + OpalHedgeBitcoinCashDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }
}
