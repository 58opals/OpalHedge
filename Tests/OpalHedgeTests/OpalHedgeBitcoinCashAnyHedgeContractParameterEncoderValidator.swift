// OpalHedgeBitcoinCashAnyHedgeContractParameterEncoderValidator.swift

import Foundation
import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractParameterEncoderValidator {
    @Test("Encodes AnyHedge v0.12 constructor parameters in stack order")
    func encodeAnyHedgeV0_12ConstructorParametersInStackOrder() throws {
        let pushes = try OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder
            .encodeConstructorStackPushes(from: makeParameterData())

        #expect(pushes.map(hexText) == [
            "03dbad65",
            "03db6409",
            "03e09903",
            "022445",
            "03353556",
            "00",
            "0500e8764817",
            "21" + OpalHedgeFixtureData.oraclePublicKeyHex,
            "19" + OpalHedgeFixtureData.longLockScriptHex,
            "19" + OpalHedgeFixtureData.shortLockScriptHex,
            "51",
            "21" + OpalHedgeFixtureData.longMutualRedeemPublicKeyHex,
            "21" + OpalHedgeFixtureData.shortMutualRedeemPublicKeyHex
        ])
    }

    @Test("Encodes AnyHedge v0.12 constructor stack bytecode")
    func encodeAnyHedgeV0_12ConstructorStackBytecode() throws {
        let parameterData = try makeParameterData()
        let pushes = try OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder
            .encodeConstructorStackPushes(from: parameterData)
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder
            .encodeConstructorStackBytecode(from: parameterData)

        #expect(bytecode == pushes.reduce(Data()) { $0 + $1 })
        #expect(bytecode.count == 181)
        #expect(hexText(bytecode).hasPrefix("03dbad6503db6409"))
        #expect(
            hexText(bytecode).hasSuffix(
                "21" + OpalHedgeFixtureData.shortMutualRedeemPublicKeyHex
            )
        )
    }

    @Test("Rejects invalid AnyHedge constructor parameter hex")
    func rejectInvalidAnyHedgeConstructorParameterHex() {
        let error = captureParameterError {
            _ = try makeParameterData(shortLockScriptHex: "zz")
        }

        #expect(error == .invalidHex(name: "shortLockScriptHex", value: "zz"))
    }

    @Test("Rejects invalid AnyHedge constructor public key")
    func rejectInvalidAnyHedgeConstructorPublicKey() {
        let error = captureParameterError {
            _ = try makeParameterData(oraclePublicKeyHex: String(repeating: "00", count: 33))
        }

        #expect(error == .invalidCompressedPublicKey(name: "oraclePublicKey", byteCount: 33))
    }

    @Test("Rejects invalid AnyHedge constructor integer")
    func rejectInvalidAnyHedgeConstructorInteger() {
        let error = captureParameterError {
            _ = try makeParameterData(enableMutualRedemption: 2)
        }

        #expect(error == .invalidBooleanInteger(name: "enableMutualRedemption", value: 2))
    }

    private func makeParameterData(
        shortMutualRedeemPublicKeyHex: String =
            OpalHedgeFixtureData.shortMutualRedeemPublicKeyHex,
        longMutualRedeemPublicKeyHex: String =
            OpalHedgeFixtureData.longMutualRedeemPublicKeyHex,
        enableMutualRedemption: Int64 = 1,
        shortLockScriptHex: String = OpalHedgeFixtureData.shortLockScriptHex,
        longLockScriptHex: String = OpalHedgeFixtureData.longLockScriptHex,
        oraclePublicKeyHex: String = OpalHedgeFixtureData.oraclePublicKeyHex
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractParameterData {
        try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
            shortMutualRedeemPublicKeyHex: shortMutualRedeemPublicKeyHex,
            longMutualRedeemPublicKeyHex: longMutualRedeemPublicKeyHex,
            enableMutualRedemption: enableMutualRedemption,
            shortLockScriptHex: shortLockScriptHex,
            longLockScriptHex: longLockScriptHex,
            oraclePublicKeyHex: oraclePublicKeyHex,
            nominalUnitsXSatsPerBch: 100_000_000_000,
            satsForNominalUnitsAtHighLiquidation: 0,
            payoutSats: 5_649_717,
            lowLiquidationPrice: 17_700,
            highLiquidationPrice: 236_000,
            startTimestamp: 615_643,
            maturityTimestamp: 6_663_643
        )
    }

    private func captureParameterError(
        _ operation: () throws -> Void
    ) -> OpalHedgeBitcoinCashAnyHedgeContractParameterError? {
        do {
            try operation()
        } catch let error as OpalHedgeBitcoinCashAnyHedgeContractParameterError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }

    private func hexText(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}
