// OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder.swift

import Foundation
import OpalDiagnostics

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
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractParametersEncoded,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("encode_constructor_stack_pushes"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.pushCount,
                        pushes.count
                    )
                ]
            )
            return pushes
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractParameterEncodingFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("encode_constructor_stack_pushes"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash")
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
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

            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractParametersEncoded,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("encode_constructor_stack_bytecode"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.byteCount,
                        bytecode.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.pushCount,
                        pushes.count
                    )
                ]
            )
            return bytecode
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractParameterEncodingFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("encode_constructor_stack_bytecode"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash")
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }
}
