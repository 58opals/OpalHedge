// OpalHedgeBitcoinCashAnyHedgeContractParameterDataValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractParameterDataValidator {
    @Test("Creates AnyHedge parameter data from Core contract plan")
    func createAnyHedgeParameterDataFromCoreContractPlan() throws {
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let parameterData = try OpalHedge.BitcoinCash.AnyHedgeContractParameterData(
            from: plan
        )
        let parametersParameterData = try OpalHedge.BitcoinCash
            .AnyHedgeContractParameterData(from: plan.parameters)

        #expect(parameterData == parametersParameterData)
    }

    @Test("Creates AnyHedge parameter data from Core contract parameters")
    func createAnyHedgeParameterDataFromCoreContractParameters() throws {
        let parameterData = try OpalHedge.BitcoinCash.AnyHedgeContractParameterData(
            from: OpalHedgeFixtureData.contractParameters
        )
        let manualParameterData = try makeManualParameterData()

        #expect(parameterData == manualParameterData)
    }

    @Test("Encodes Core contract plan as AnyHedge constructor bytecode")
    func encodeCoreContractPlanAsAnyHedgeConstructorBytecode() throws {
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let parameterData = try OpalHedge.BitcoinCash.AnyHedgeContractParameterData(
            from: plan
        )
        let bytecode = try OpalHedge.BitcoinCash.AnyHedgeContractParameterEncoder
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
        let parameterData = try OpalHedge.BitcoinCash.AnyHedgeContractParameterData(
            from: OpalHedgeFixtureData.contractParameters
        )
        let bytecode = try OpalHedge.BitcoinCash.AnyHedgeContractParameterEncoder
            .encodeConstructorStackBytecode(from: parameterData)

        #expect(bytecode.count == 181)
        #expect(hexText(bytecode).hasPrefix("03dbad6503db6409"))
        #expect(
            hexText(bytecode).hasSuffix(
                "21" + OpalHedgeFixtureData.shortMutualRedeemPublicKeyHex
            )
        )
    }

    private func makeManualParameterData() throws -> OpalHedge.BitcoinCash
        .AnyHedgeContractParameterData {
        try OpalHedge.BitcoinCash.AnyHedgeContractParameterData(
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
