// OpalHedgeBitcoinCashAnyHedgeContractBytecodeValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractBytecodeValidator {
    @Test("Creates AnyHedge contract bytecode from parameter data")
    func createAnyHedgeContractBytecodeFromParameterData() throws {
        let parameterData = try OpalHedge.BitcoinCash.AnyHedgeContractParameterData(
            from: OpalHedgeFixtureData.contractParameters
        )
        let bytecode = try OpalHedge.BitcoinCash.AnyHedgeContractBytecode(
            parameters: parameterData
        )

        #expect(bytecode.artifact == .anyHedgeV0_12)
        #expect(bytecode.constructorStackPushes.count == 13)
        #expect(bytecode.constructorStackBytecode.count == 181)
        #expect(hexText(bytecode.constructorStackBytecode).hasPrefix("03dbad6503db6409"))
    }

    @Test("Composes AnyHedge redeem script bytecode")
    func composeAnyHedgeRedeemScriptBytecode() throws {
        let bytecode = try OpalHedge.BitcoinCash.AnyHedgeContractBytecode(
            from: OpalHedgeFixtureData.contractParameters
        )
        let constructorPrefix = bytecode.redeemScriptBytecode.prefix(
            bytecode.constructorStackBytecode.count
        )
        let scriptSuffix = bytecode.redeemScriptBytecode.suffix(
            bytecode.scriptBytecode.rawData.count
        )

        #expect(bytecode.redeemScriptBytecode.count == 343)
        #expect(Data(constructorPrefix) == bytecode.constructorStackBytecode)
        #expect(Data(scriptSuffix) == bytecode.scriptBytecode.rawData)
        #expect(hexText(bytecode.redeemScriptBytecode).hasPrefix("03dbad6503db6409"))
        #expect(hexText(bytecode.redeemScriptBytecode).hasSuffix("cd547a8777777768"))
    }

    @Test("Derives AnyHedge contract address from redeem script bytecode")
    func deriveAnyHedgeContractAddressFromRedeemScriptBytecode() throws {
        let bytecode = try OpalHedge.BitcoinCash.AnyHedgeContractBytecode(
            from: OpalHedgeFixtureData.contractParameters
        )
        let address = try bytecode.deriveContractAddress(network: .mainnet)
        let directAddress = try OpalHedge.BitcoinCash.ContractAddress(
            redeemScript: bytecode.redeemScriptBytecode,
            network: .mainnet
        )

        #expect(hexText(address.scriptHash) == "6cf774143b35046148a90f3f9024b2fd96541e5c")
        #expect(address.rawValue == "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx")
        #expect(address == directAddress)
    }

    @Test("Creates AnyHedge contract bytecode from Core contract plan")
    func createAnyHedgeContractBytecodeFromCoreContractPlan() throws {
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let bytecode = try OpalHedge.BitcoinCash.AnyHedgeContractBytecode(
            from: plan
        )
        let parametersBytecode = try OpalHedge.BitcoinCash.AnyHedgeContractBytecode(
            from: plan.parameters
        )

        #expect(bytecode == parametersBytecode)
    }

    @Test("Preserves explicit AnyHedge contract script artifact")
    func preserveExplicitAnyHedgeContractScriptArtifact() throws {
        let artifact = OpalHedge.BitcoinCash.ContractScriptArtifact(
            version: OpalHedge.BitcoinCash.ContractScriptArtifactVersion(
                rawValue: "v0.12-fixture",
                displayName: "AnyHedge v0.12 Fixture",
                contractDirectoryPath: "contracts/v0.12"
            ),
            packageName: "@generalprotocols/anyhedge-contracts",
            sourceCodeUrl: "https://example.invalid/contract.cash",
            bytecodeAssemblyUrl: "https://example.invalid/bytecode.asm",
            artifactJsonUrl: "https://example.invalid/artifact.json"
        )
        let scriptBytecode = OpalHedge.BitcoinCash.AnyHedgeContractScriptBytecode(
            artifact: artifact,
            rawHex: OpalHedge.BitcoinCash.AnyHedgeContractScriptBytecode
                .anyHedgeV0_12.rawHex,
            rawData: OpalHedge.BitcoinCash.AnyHedgeContractScriptBytecode
                .anyHedgeV0_12.rawData
        )
        let bytecode = try OpalHedge.BitcoinCash.AnyHedgeContractBytecode(
            from: OpalHedgeFixtureData.contractParameters,
            scriptBytecode: scriptBytecode
        )

        #expect(bytecode.artifact == artifact)
        #expect(bytecode.scriptBytecode == scriptBytecode)
        #expect(bytecode.constructorStackBytecode.count == 181)
    }

    private func hexText(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}
