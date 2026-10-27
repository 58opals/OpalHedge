// OpalHedgeArtifactProvenanceValidator.swift

import CryptoKit
import Foundation
import OpalHedgeBitcoinCash
import Testing

struct OpalHedgeArtifactProvenanceValidator {
    @Test("Bind AnyHedge descriptors to the reviewed immutable artifact revision")
    func bindDescriptorsToReviewedRevision() throws {
        let artifact = OpalHedgeBitcoinCashContractScriptArtifact.anyHedgeV0_12
        let sourceRoot = "https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/raw/"
            + OpalHedgeArtifactProvenanceData.upstreamRevision + "/contracts/v0.12/"

        #expect(artifact.sourceCodeUrl == sourceRoot + "contract.cash")
        #expect(artifact.bytecodeAssemblyUrl == sourceRoot + "bytecode.asm")
        #expect(artifact.artifactJsonUrl == sourceRoot + "artifact.json")

        let noticeURL = URL(filePath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().appending(path: "Docs/AnyHedgeProvenance.md")
        let notice = try String(contentsOf: noticeURL, encoding: .utf8)
        #expect(notice.contains(OpalHedgeArtifactProvenanceData.upstreamRevision))
        #expect(notice.contains(OpalHedgeArtifactProvenanceData.upstreamArtifactSHA256))
        #expect(notice.contains(OpalHedgeArtifactProvenanceData.programSHA256))
        #expect(notice.contains(OpalHedgeArtifactProvenanceData.tenWeekConstructorSHA256))
    }

    @Test("Preserve the reviewed program and ten-week constructor byte identities")
    func preserveReviewedByteIdentities() throws {
        let program = OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode.anyHedgeV0_12
        let bytecode = try OpalHedgeBitcoinCashAnyHedgeContractBytecode(
            from: OpalHedgeFixtureData.contractParameters
        )

        #expect(sha256(program.rawScriptData) == OpalHedgeArtifactProvenanceData.programSHA256)
        #expect(
            sha256(bytecode.rawConstructorStackBytecode)
                == OpalHedgeArtifactProvenanceData.tenWeekConstructorSHA256
        )
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
