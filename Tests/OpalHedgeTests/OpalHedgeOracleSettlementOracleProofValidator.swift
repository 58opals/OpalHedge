// OpalHedgeOracleSettlementOracleProofValidator.swift

import Testing
import OpalHedge

struct OpalHedgeOracleSettlementOracleProofValidator {
    @Test("Verifies settlement oracle proof")
    func verifySettlementOracleProof() throws {
        let proof = try OpalHedge.Oracle.verifySettlementOracleProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex.uppercased(),
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )

        #expect(proof.message == OpalHedgeFixtureData.contractOracleMessageData)
        #expect(proof.signature == OpalHedgeFixtureData.contractOracleSignature)
        #expect(proof.messageHex == OpalHedgeFixtureData.startingOracleMessageHex)
        #expect(proof.signatureHex == OpalHedgeFixtureData.startingOracleSignatureHex)
    }

    @Test("Normalizes verified settlement oracle proof signature whitespace")
    func normalizeVerifiedSettlementOracleProofSignatureWhitespace() throws {
        let proof = try OpalHedge.Oracle.verifySettlementOracleProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: "\n\(OpalHedgeFixtureData.startingOracleSignatureHex.uppercased()) ",
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )

        #expect(proof.signatureHex == OpalHedgeFixtureData.startingOracleSignatureHex)
    }

    @Test("Rejects invalid settlement oracle signature")
    func rejectInvalidSettlementOracleSignature() {
        let error = OpalHedgeTypedErrorCaptureTool.captureSettlementOracleProofError {
            _ = try OpalHedge.Oracle.verifySettlementOracleProof(
                messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
                signatureHex: makeInvalidSignatureHex(),
                publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
            )
        }

        #expect(error == .invalidSignature)
    }

    private func makeInvalidSignatureHex() -> String {
        let finalCharacter = OpalHedgeFixtureData.startingOracleSignatureHex.hasSuffix("0") ?
            "1" :
            "0"

        return String(OpalHedgeFixtureData.startingOracleSignatureHex.dropLast()) +
            finalCharacter
    }
}
