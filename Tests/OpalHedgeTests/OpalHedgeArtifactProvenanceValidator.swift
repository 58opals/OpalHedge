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
        #expect(notice.contains(OpalHedgeArtifactProvenanceData.libraryRevision))
        #expect(notice.contains(OpalHedgeArtifactProvenanceData.tenWeekSourceSHA256))
        #expect(notice.contains(OpalHedgeArtifactProvenanceData.tenWeekParametersSHA256))
        #expect(notice.contains(OpalHedgeArtifactProvenanceData.tenWeekOracleProofSHA256))
        #expect(notice.contains("54c48b616d478b0c945160cfd883ea110efe9e4ba64a4c4c0f8e66db32c59028"))
        #expect(notice.contains("57be465842d82933dbb4d28c03797582db79a086cd943b4621799e837f87c4ca"))
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

    @Test("Preserve the upstream-matched ten-week constructor and oracle inputs")
    func preserveQualifiedTenWeekConstructorInputs() throws {
        let document = try #require(JSONSerialization.jsonObject(
            with: Data(OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText.utf8)
        ) as? [String: Any])
        let parameters = try #require(document["parameters"] as? [String: Any])
        #expect(parameters.count == 13)
        let aliases = [
            "hedgeLockScript": "shortLockScript",
            "hedgeMutualRedeemPublicKey": "shortMutualRedeemPublicKey"
        ]
        let rows = try parameters.keys.map { name in
            let value: String
            if let text = parameters[name] as? String { value = text }
            else { value = try #require(parameters[name] as? NSNumber).stringValue }
            return (aliases[name] ?? name) + "=" + value
        }.sorted().joined(separator: "\n") + "\n"
        #expect(
            sha256(Data(rows.utf8))
                == OpalHedgeArtifactProvenanceData.tenWeekParametersSHA256
        )
        let oracleFields = [
            OpalHedgeFixtureData.oraclePublicKeyHex,
            OpalHedgeFixtureData.startingOracleMessageHex,
            OpalHedgeFixtureData.startingOracleSignatureHex
        ].joined(separator: "\n") + "\n"
        #expect(
            sha256(Data(oracleFields.utf8))
                == OpalHedgeArtifactProvenanceData.tenWeekOracleProofSHA256
        )
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
