// OpalHedgeBitcoinCashAnyHedgeContractScriptBytecodeValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractScriptBytecodeValidator {
    @Test("Provides AnyHedge v0.12 script bytecode reference")
    func provideAnyHedgeV0_12ScriptBytecodeReference() {
        let scriptBytecode = OpalHedge.BitcoinCash.AnyHedgeContractScriptBytecode
            .anyHedgeV0_12

        #expect(scriptBytecode.artifact == .anyHedgeV0_12)
        #expect(scriptBytecode.rawData.count == 162)
        #expect(scriptBytecode.rawHex.count == 324)
        #expect(scriptBytecode.rawHex.hasPrefix("5d79009c637b695d"))
        #expect(scriptBytecode.rawHex.hasSuffix("77777768"))
        #expect(hexText(scriptBytecode.rawData) == scriptBytecode.rawHex)
    }

    @Test("Includes AnyHedge v0.12 script bytecode in contract bytecode")
    func includeAnyHedgeV0_12ScriptBytecodeInContractBytecode() throws {
        let bytecode = try OpalHedge.BitcoinCash.AnyHedgeContractBytecode(
            from: OpalHedgeFixtureData.contractParameters
        )

        #expect(bytecode.scriptBytecode == .anyHedgeV0_12)
        #expect(bytecode.artifact == .anyHedgeV0_12)
        #expect(bytecode.constructorStackBytecode.count == 181)
    }

    private func hexText(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}
