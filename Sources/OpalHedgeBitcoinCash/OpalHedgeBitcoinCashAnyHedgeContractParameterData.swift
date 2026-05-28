// OpalHedgeBitcoinCashAnyHedgeContractParameterData.swift

import Foundation
import OpalDiagnostics

public struct OpalHedgeBitcoinCashAnyHedgeContractParameterData: Sendable, Equatable {
    public let shortMutualRedeemPublicKey: Data
    public let longMutualRedeemPublicKey: Data
    public let enableMutualRedemption: Int64
    public let shortLockScript: Data
    public let longLockScript: Data
    public let oraclePublicKey: Data
    public let nominalUnitsXSatsPerBch: Int64
    public let satsForNominalUnitsAtHighLiquidation: Int64
    public let payoutSats: Int64
    public let lowLiquidationPrice: Int64
    public let highLiquidationPrice: Int64
    public let startTimestamp: Int64
    public let maturityTimestamp: Int64

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
        do {
            try Self.validateCompressedPublicKey(
                shortMutualRedeemPublicKey,
                name: "shortMutualRedeemPublicKey"
            )
            try Self.validateCompressedPublicKey(
                longMutualRedeemPublicKey,
                name: "longMutualRedeemPublicKey"
            )
            try Self.validateCompressedPublicKey(
                oraclePublicKey,
                name: "oraclePublicKey"
            )
            try Self.validatePayToPublicKeyHashLockScript(
                shortLockScript,
                name: "shortLockScript"
            )
            try Self.validatePayToPublicKeyHashLockScript(
                longLockScript,
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

            self.shortMutualRedeemPublicKey = shortMutualRedeemPublicKey
            self.longMutualRedeemPublicKey = longMutualRedeemPublicKey
            self.enableMutualRedemption = enableMutualRedemption
            self.shortLockScript = shortLockScript
            self.longLockScript = longLockScript
            self.oraclePublicKey = oraclePublicKey
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
            shortMutualRedeemPublicKey: Self.decodeHex(
                shortMutualRedeemPublicKeyHex,
                name: "shortMutualRedeemPublicKeyHex"
            ),
            longMutualRedeemPublicKey: Self.decodeHex(
                longMutualRedeemPublicKeyHex,
                name: "longMutualRedeemPublicKeyHex"
            ),
            enableMutualRedemption: enableMutualRedemption,
            shortLockScript: Self.decodeHex(shortLockScriptHex, name: "shortLockScriptHex"),
            longLockScript: Self.decodeHex(longLockScriptHex, name: "longLockScriptHex"),
            oraclePublicKey: Self.decodeHex(oraclePublicKeyHex, name: "oraclePublicKeyHex"),
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

    private static func validateCompressedPublicKey(_ value: Data, name: String) throws {
        guard value.count == compressedPublicKeyByteCount,
              let firstByte = value.first,
              compressedPublicKeyPrefixes.contains(firstByte) else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidCompressedPublicKey(name: name, byteCount: value.count)
        }
    }

    private static func validatePayToPublicKeyHashLockScript(
        _ value: Data,
        name: String
    ) throws {
        guard value.count == payToPublicKeyHashLockScriptByteCount,
              value.starts(with: payToPublicKeyHashLockScriptPrefix),
              value.suffix(payToPublicKeyHashLockScriptSuffix.count) ==
              payToPublicKeyHashLockScriptSuffix else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidLockScript(name: name, byteCount: value.count)
        }
    }

    private static func validatePositiveInteger(_ value: Int64, name: String) throws {
        guard value > 0 else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidPositiveInteger(name: name, value: value)
        }
    }

    private static func validateFourBytePositiveScriptInteger(
        _ value: Int64,
        name: String
    ) throws {
        try validatePositiveInteger(value, name: name)
        guard value <= maxFourByteScriptInteger else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidPositiveInteger(name: name, value: value)
        }
    }

    private static func validateIncreasingIntegerRange(
        lower: Int64,
        upper: Int64,
        upperName: String
    ) throws {
        guard upper > lower else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidPositiveInteger(name: upperName, value: upper)
        }
    }

    private static func validateNonnegativeInteger(_ value: Int64, name: String) throws {
        guard value >= 0 else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidNonnegativeInteger(name: name, value: value)
        }
    }

    private static func validateBooleanInteger(_ value: Int64, name: String) throws {
        guard value == 0 || value == 1 else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidBooleanInteger(name: name, value: value)
        }
    }

    private static func validatePayoutSatoshis(_ value: Int64) throws {
        guard value >= dustLimitSatoshis,
              value <= maxContractSatoshis else {
            throw OpalHedgeBitcoinCashAnyHedgeContractParameterError
                .invalidPositiveInteger(name: "payoutSats", value: value)
        }
    }

    private static let compressedPublicKeyByteCount = 33
    private static let payToPublicKeyHashLockScriptByteCount = 25
    private static let maxFourByteScriptInteger = Int64(Int32.max)
    private static let dustLimitSatoshis: Int64 = 1_332
    private static let maxContractSatoshis: Int64 = 10_000_000_000_000

    private static let payToPublicKeyHashLockScriptPrefix = Data([0x76, 0xa9, 0x14])
    private static let payToPublicKeyHashLockScriptSuffix = Data([0x88, 0xac])
    private static let compressedPublicKeyPrefixes: Set<UInt8> = [0x02, 0x03]
}
