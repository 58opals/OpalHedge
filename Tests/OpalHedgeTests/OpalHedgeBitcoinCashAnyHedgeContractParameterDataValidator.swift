// OpalHedgeBitcoinCashAnyHedgeContractParameterDataValidator.swift

import Foundation
import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractParameterDataValidator {
    @Test("Creates AnyHedge parameter data from Core contract plan")
    func createAnyHedgeParameterDataFromCoreContractPlan() throws {
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let parameterData = try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
            from: plan
        )
        let parametersParameterData = try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
            from: plan.parameters
        )

        #expect(parameterData == parametersParameterData)
    }

    @Test("Creates AnyHedge parameter data from Core contract parameters")
    func createAnyHedgeParameterDataFromCoreContractParameters() throws {
        let parameterData = try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
            from: OpalHedgeFixtureData.contractParameters
        )
        let manualParameterData = try makeManualParameterData()

        #expect(parameterData == manualParameterData)
    }

    @Test("Exposes raw AnyHedge constructor material with explicit names")
    func exposeRawAnyHedgeConstructorMaterialWithExplicitNames() throws {
        let parameterData = try makeManualParameterData()

        #expect(hexText(parameterData.rawOraclePublicKey) == OpalHedgeFixtureData.oraclePublicKeyHex)
        #expect(hexText(parameterData.rawLongLockScript) == OpalHedgeFixtureData.longLockScriptHex)
        #expect(hexText(parameterData.rawShortLockScript) == OpalHedgeFixtureData.shortLockScriptHex)
        #expect(
            hexText(parameterData.rawLongMutualRedeemPublicKey) ==
                OpalHedgeFixtureData.longMutualRedeemPublicKeyHex
        )
        #expect(
            hexText(parameterData.rawShortMutualRedeemPublicKey) ==
                OpalHedgeFixtureData.shortMutualRedeemPublicKeyHex
        )
    }

    @Test("Encodes Core contract plan as AnyHedge constructor bytecode")
    func encodeCoreContractPlanAsAnyHedgeConstructorBytecode() throws {
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let parameterData = try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
            from: plan
        )
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder
            .encodeConstructorStackBytecode(from: parameterData)

        #expect(bytecode.count == 181)
        #expect(hexText(bytecode).hasPrefix("03dbad6503db6409"))
        #expect(
            hexText(bytecode).hasSuffix(
                "21" + OpalHedgeFixtureData.shortMutualRedeemPublicKeyHex
            )
        )
    }

    @Test("Encodes Core contract parameters as AnyHedge constructor bytecode")
    func encodeCoreContractParametersAsAnyHedgeConstructorBytecode() throws {
        let parameterData = try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
            from: OpalHedgeFixtureData.contractParameters
        )
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder
            .encodeConstructorStackBytecode(from: parameterData)

        #expect(bytecode.count == 181)
        #expect(hexText(bytecode).hasPrefix("03dbad6503db6409"))
        #expect(
            hexText(bytecode).hasSuffix(
                "21" + OpalHedgeFixtureData.shortMutualRedeemPublicKeyHex
            )
        )
    }

    private func makeManualParameterData()
        throws -> OpalHedgeBitcoinCashAnyHedgeContractParameterData {
        try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
            shortMutualRedeemPublicKeyHex: OpalHedgeFixtureData
                .shortMutualRedeemPublicKeyHex,
            longMutualRedeemPublicKeyHex: OpalHedgeFixtureData
                .longMutualRedeemPublicKeyHex,
            enableMutualRedemption: 1,
            shortLockScriptHex: OpalHedgeFixtureData.shortLockScriptHex,
            longLockScriptHex: OpalHedgeFixtureData.longLockScriptHex,
            oraclePublicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex,
            nominalUnitsXSatsPerBch: 100_000_000_000,
            satsForNominalUnitsAtHighLiquidation: 0,
            payoutSats: 5_649_717,
            lowLiquidationPrice: 17_700,
            highLiquidationPrice: 236_000,
            startTimestamp: 615_643,
            maturityTimestamp: 6_663_643
        )
    }

    private func hexText(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}
