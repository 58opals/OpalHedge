// OpalHedgeBitcoinCashAnyHedgeContractBytecodeValidator.swift

import Foundation
import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractBytecodeValidator {
    @Test("Creates AnyHedge contract bytecode from parameter data")
    func createAnyHedgeContractBytecodeFromParameterData() throws {
        let parameterData = try OpalHedgeBitcoinCashAnyHedgeContractParameterData(
            from: OpalHedgeFixtureData.contractParameters
        )
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            parameters: parameterData
        )

        #expect(bytecode.artifact == .anyHedgeV0_12)
        #expect(bytecode.rawConstructorStackPushes.count == 13)
        #expect(bytecode.rawConstructorStackBytecode.count == 181)
        #expect(makeHexText(bytecode.rawConstructorStackBytecode).hasPrefix("03dbad6503db6409"))
    }

    @Test("Composes AnyHedge redeem script bytecode")
    func composeAnyHedgeRedeemScriptBytecode() throws {
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            from: OpalHedgeFixtureData.contractParameters
        )
        let constructorPrefix = bytecode.rawRedeemScriptBytecode.prefix(
            bytecode.rawConstructorStackBytecode.count
        )
        let scriptSuffix = bytecode.rawRedeemScriptBytecode.suffix(
            bytecode.scriptBytecode.rawScriptData.count
        )
        let redeemScriptHexText = makeHexText(bytecode.rawRedeemScriptBytecode)

        #expect(bytecode.rawRedeemScriptBytecode.count == 343)
        #expect(Data(constructorPrefix) == bytecode.rawConstructorStackBytecode)
        #expect(Data(scriptSuffix) == bytecode.scriptBytecode.rawScriptData)
        #expect(redeemScriptHexText.hasPrefix("03dbad6503db6409"))
        #expect(redeemScriptHexText.hasSuffix("cd547a8777777768"))
    }

    @Test("Derives AnyHedge contract address from redeem script bytecode")
    func deriveAnyHedgeContractAddressFromRedeemScriptBytecode() throws {
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            from: OpalHedgeFixtureData.contractParameters
        )
        let address = try bytecode.deriveContractAddress(network: .mainnet)
        let directAddress = try OpalHedgeBitcoinCashContractAddress(
            rawRedeemScript: bytecode.rawRedeemScriptBytecode,
            network: .mainnet
        )

        #expect(makeHexText(address.rawScriptHash) == "6cf774143b35046148a90f3f9024b2fd96541e5c")
        #expect(address.rawValue == "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx")
        #expect(address == directAddress)
    }

    @Test("Creates AnyHedge contract bytecode from Core contract plan")
    func createAnyHedgeContractBytecodeFromCoreContractPlan() throws {
        let plan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            from: plan
        )
        let parametersBytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            from: plan.parameters
        )

        #expect(bytecode == parametersBytecode)
    }

    @Test("Preserves explicit AnyHedge contract script artifact")
    func preserveExplicitAnyHedgeContractScriptArtifact() throws {
        let artifact = OpalHedgeBitcoinCashContractScriptArtifact(
            version: OpalHedgeBitcoinCashContractScriptArtifactVersion(
                rawValue: "v0.12-fixture",
                displayName: "AnyHedge v0.12 Fixture",
                contractDirectoryPath: "contracts/v0.12"
            ),
            packageName: "@generalprotocols/anyhedge-contracts",
            sourceCodeUrl: "https://example.invalid/contract.cash",
            bytecodeAssemblyUrl: "https://example.invalid/bytecode.asm",
            artifactJsonUrl: "https://example.invalid/artifact.json"
        )
        let scriptBytecode = OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode(
            artifact: artifact,
            rawScriptHex: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
                .anyHedgeV0_12.rawScriptHex,
            rawScriptData: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
                .anyHedgeV0_12.rawScriptData
        )
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            from: OpalHedgeFixtureData.contractParameters,
            scriptBytecode: scriptBytecode
        )

        #expect(bytecode.artifact == artifact)
        #expect(bytecode.scriptBytecode == scriptBytecode)
        #expect(bytecode.rawConstructorStackBytecode.count == 181)
    }

    private func makeHexText(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}
