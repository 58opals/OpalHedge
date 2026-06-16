// OpalHedgeBitcoinCashAnyHedgeContractScriptBytecodeValidator.swift

import Foundation
import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractScriptBytecodeValidator {
    @Test("Provides AnyHedge v0.12 script bytecode reference")
    func provideAnyHedgeV0_12ScriptBytecodeReference() {
        let scriptBytecode = OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
            .anyHedgeV0_12

        #expect(scriptBytecode.artifact == .anyHedgeV0_12)
        #expect(scriptBytecode.rawScriptData.count == 162)
        #expect(scriptBytecode.rawScriptHex.count == 324)
        #expect(scriptBytecode.rawScriptHex.hasPrefix("5d79009c637b695d"))
        #expect(scriptBytecode.rawScriptHex.hasSuffix("77777768"))
        #expect(makeHexText(scriptBytecode.rawScriptData) == scriptBytecode.rawScriptHex)
    }

    @Test("Includes AnyHedge v0.12 script bytecode in contract bytecode")
    func includeAnyHedgeV0_12ScriptBytecodeInContractBytecode() throws {
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            from: OpalHedgeFixtureData.contractParameters
        )

        #expect(bytecode.scriptBytecode == .anyHedgeV0_12)
        #expect(bytecode.artifact == .anyHedgeV0_12)
        #expect(bytecode.rawConstructorStackBytecode.count == 181)
    }

    private func makeHexText(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}
