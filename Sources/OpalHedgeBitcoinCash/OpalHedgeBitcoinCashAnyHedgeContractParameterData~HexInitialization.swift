// OpalHedgeBitcoinCashAnyHedgeContractParameterData~HexInitialization.swift

import Foundation
import OpalDiagnostics

extension OpalHedgeBitcoinCashAnyHedgeContractParameterData {
    public init(
        shortMutualRedeemPublicKeyHex: String,
        longMutualRedeemPublicKeyHex: String,
        enableMutualRedemption: Int64,
        shortLockScriptHex: String,
        longLockScriptHex: String,
        oraclePublicKeyHex: String,
        nominalUnitsXSatsPerBch: Int64,
        satsForNominalUnitsAtHighLiquidation: Int64,
        payoutSats: Int64,
        lowLiquidationPrice: Int64,
        highLiquidationPrice: Int64,
        startTimestamp: Int64,
        maturityTimestamp: Int64
    ) throws {
        try self.init(
            rawShortMutualRedeemPublicKey: Self.decodeHex(
                shortMutualRedeemPublicKeyHex,
                name: "shortMutualRedeemPublicKeyHex"
            ),
            rawLongMutualRedeemPublicKey: Self.decodeHex(
                longMutualRedeemPublicKeyHex,
                name: "longMutualRedeemPublicKeyHex"
            ),
            enableMutualRedemption: enableMutualRedemption,
            rawShortLockScript: Self.decodeHex(shortLockScriptHex, name: "shortLockScriptHex"),
            rawLongLockScript: Self.decodeHex(longLockScriptHex, name: "longLockScriptHex"),
            rawOraclePublicKey: Self.decodeHex(oraclePublicKeyHex, name: "oraclePublicKeyHex"),
            nominalUnitsXSatsPerBch: nominalUnitsXSatsPerBch,
            satsForNominalUnitsAtHighLiquidation: satsForNominalUnitsAtHighLiquidation,
            payoutSats: payoutSats,
            lowLiquidationPrice: lowLiquidationPrice,
            highLiquidationPrice: highLiquidationPrice,
            startTimestamp: startTimestamp,
            maturityTimestamp: maturityTimestamp
        )
    }

    private static func decodeHex(_ hex: String, name: String) throws -> Data {
        guard let data = OpalHedgeBitcoinCashHexadecimalCodec.decode(hex) else {
            let error = OpalHedgeBitcoinCashAnyHedgeContractParameterError.invalidHex(
                name: name,
                value: hex
            )
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractParameterEncodingFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("decode_contract_parameter_hex"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        name
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }

        return data
    }
}
