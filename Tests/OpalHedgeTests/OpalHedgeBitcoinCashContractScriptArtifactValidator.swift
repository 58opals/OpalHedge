// OpalHedgeBitcoinCashContractScriptArtifactValidator.swift

import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashContractScriptArtifactValidator {
    @Test("Provides AnyHedge v0.12 script artifact version")
    func provideAnyHedgeScriptArtifactVersion() {
        let version = OpalHedgeBitcoinCashContractScriptArtifactVersion
            .anyHedgeV0_12

        #expect(version.rawValue == "v0.12")
        #expect(version.displayName == "AnyHedge v0.12")
        #expect(version.contractDirectoryPath == "contracts/v0.12")
    }

    @Test("Provides AnyHedge v0.12 script artifact reference")
    func provideAnyHedgeScriptArtifactReference() {
        let artifact = OpalHedgeBitcoinCashContractScriptArtifact
            .anyHedgeV0_12

        #expect(artifact.version == .anyHedgeV0_12)
        #expect(artifact.packageName == "@generalprotocols/anyhedge-contracts")
        #expect(artifact.sourceCodeUrl.hasSuffix("/contracts/v0.12/contract.cash"))
        #expect(artifact.bytecodeAssemblyUrl.hasSuffix("/contracts/v0.12/bytecode.asm"))
        #expect(artifact.artifactJsonUrl.hasSuffix("/contracts/v0.12/artifact.json"))
    }
}
