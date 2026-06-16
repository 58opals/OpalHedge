// OpalHedgeBitcoinCashAnyHedgeContractParameterData.swift

import Foundation
import OpalDiagnostics

public struct OpalHedgeBitcoinCashAnyHedgeContractParameterData: Sendable, Equatable {
    public let rawShortMutualRedeemPublicKey: Data
    public let rawLongMutualRedeemPublicKey: Data
    public let enableMutualRedemption: Int64
    public let rawShortLockScript: Data
    public let rawLongLockScript: Data
    public let rawOraclePublicKey: Data
    public let nominalUnitsXSatsPerBch: Int64
    public let satsForNominalUnitsAtHighLiquidation: Int64
    public let payoutSats: Int64
    public let lowLiquidationPrice: Int64
    public let highLiquidationPrice: Int64
    public let startTimestamp: Int64
    public let maturityTimestamp: Int64

    @available(*, deprecated, renamed: "rawShortMutualRedeemPublicKey")
    public var shortMutualRedeemPublicKey: Data {
        rawShortMutualRedeemPublicKey
    }

    @available(*, deprecated, renamed: "rawLongMutualRedeemPublicKey")
    public var longMutualRedeemPublicKey: Data {
        rawLongMutualRedeemPublicKey
    }

    @available(*, deprecated, renamed: "rawShortLockScript")
    public var shortLockScript: Data {
        rawShortLockScript
    }

    @available(*, deprecated, renamed: "rawLongLockScript")
    public var longLockScript: Data {
        rawLongLockScript
    }

    @available(*, deprecated, renamed: "rawOraclePublicKey")
    public var oraclePublicKey: Data {
        rawOraclePublicKey
    }

    public init(
        rawShortMutualRedeemPublicKey: Data,
        rawLongMutualRedeemPublicKey: Data,
        enableMutualRedemption: Int64,
        rawShortLockScript: Data,
        rawLongLockScript: Data,
        rawOraclePublicKey: Data,
        nominalUnitsXSatsPerBch: Int64,
        satsForNominalUnitsAtHighLiquidation: Int64,
        payoutSats: Int64,
        lowLiquidationPrice: Int64,
        highLiquidationPrice: Int64,
        startTimestamp: Int64,
        maturityTimestamp: Int64
    ) throws {
        do {
            try Self.validateCompressedPublicKey(
                rawShortMutualRedeemPublicKey,
                name: "shortMutualRedeemPublicKey"
            )
            try Self.validateCompressedPublicKey(
                rawLongMutualRedeemPublicKey,
                name: "longMutualRedeemPublicKey"
            )
            try Self.validateCompressedPublicKey(
                rawOraclePublicKey,
                name: "oraclePublicKey"
            )
            try Self.validatePayToPublicKeyHashLockScript(
                rawShortLockScript,
                name: "shortLockScript"
            )
            try Self.validatePayToPublicKeyHashLockScript(
                rawLongLockScript,
                name: "longLockScript"
            )
            try Self.validateBooleanInteger(
                enableMutualRedemption,
                name: "enableMutualRedemption"
            )
            try Self.validatePositiveInteger(
                nominalUnitsXSatsPerBch,
                name: "nominalUnitsXSatsPerBch"
            )
            try Self.validateNonnegativeInteger(
                satsForNominalUnitsAtHighLiquidation,
                name: "satsForNominalUnitsAtHighLiquidation"
            )
            try Self.validatePayoutSatoshis(payoutSats)
            try Self.validateFourBytePositiveScriptInteger(
                lowLiquidationPrice,
                name: "lowLiquidationPrice"
            )
            try Self.validateFourBytePositiveScriptInteger(
                highLiquidationPrice,
                name: "highLiquidationPrice"
            )
            try Self.validateIncreasingIntegerRange(
                lower: lowLiquidationPrice,
                upper: highLiquidationPrice,
                upperName: "highLiquidationPrice"
            )
            try Self.validateFourBytePositiveScriptInteger(startTimestamp, name: "startTimestamp")
            try Self.validateFourBytePositiveScriptInteger(
                maturityTimestamp,
                name: "maturityTimestamp"
            )
            try Self.validateIncreasingIntegerRange(
                lower: startTimestamp,
                upper: maturityTimestamp,
                upperName: "maturityTimestamp"
            )

            self.rawShortMutualRedeemPublicKey = rawShortMutualRedeemPublicKey
            self.rawLongMutualRedeemPublicKey = rawLongMutualRedeemPublicKey
            self.enableMutualRedemption = enableMutualRedemption
            self.rawShortLockScript = rawShortLockScript
            self.rawLongLockScript = rawLongLockScript
            self.rawOraclePublicKey = rawOraclePublicKey
            self.nominalUnitsXSatsPerBch = nominalUnitsXSatsPerBch
            self.satsForNominalUnitsAtHighLiquidation = satsForNominalUnitsAtHighLiquidation
            self.payoutSats = payoutSats
            self.lowLiquidationPrice = lowLiquidationPrice
            self.highLiquidationPrice = highLiquidationPrice
            self.startTimestamp = startTimestamp
            self.maturityTimestamp = maturityTimestamp
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractParametersEncoded,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("create_contract_parameter_data"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash")
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractParameterEncodingFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("create_contract_parameter_data"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash")
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    @available(*, deprecated, message: "Use init(rawShortMutualRedeemPublicKey:rawLongMutualRedeemPublicKey:enableMutualRedemption:rawShortLockScript:rawLongLockScript:rawOraclePublicKey:nominalUnitsXSatsPerBch:satsForNominalUnitsAtHighLiquidation:payoutSats:lowLiquidationPrice:highLiquidationPrice:startTimestamp:maturityTimestamp:) so raw BCH constructor material is explicit.")
    public init(
        shortMutualRedeemPublicKey: Data,
        longMutualRedeemPublicKey: Data,
        enableMutualRedemption: Int64,
        shortLockScript: Data,
        longLockScript: Data,
        oraclePublicKey: Data,
        nominalUnitsXSatsPerBch: Int64,
        satsForNominalUnitsAtHighLiquidation: Int64,
        payoutSats: Int64,
        lowLiquidationPrice: Int64,
        highLiquidationPrice: Int64,
        startTimestamp: Int64,
        maturityTimestamp: Int64
    ) throws {
        try self.init(
            rawShortMutualRedeemPublicKey: shortMutualRedeemPublicKey,
            rawLongMutualRedeemPublicKey: longMutualRedeemPublicKey,
            enableMutualRedemption: enableMutualRedemption,
            rawShortLockScript: shortLockScript,
            rawLongLockScript: longLockScript,
            rawOraclePublicKey: oraclePublicKey,
            nominalUnitsXSatsPerBch: nominalUnitsXSatsPerBch,
            satsForNominalUnitsAtHighLiquidation: satsForNominalUnitsAtHighLiquidation,
            payoutSats: payoutSats,
            lowLiquidationPrice: lowLiquidationPrice,
            highLiquidationPrice: highLiquidationPrice,
            startTimestamp: startTimestamp,
            maturityTimestamp: maturityTimestamp
        )
    }
}
