// OpalHedgeOracleStartingPriceProofValidator.swift

import Testing
import OpalHedge

struct OpalHedgeOracleStartingPriceProofValidator {
    @Test("Verifies upstream starting price proof")
    func verifyUpstreamStartingPriceProof() throws {
        let proof = try OpalHedge.Oracle.verifyStartingPriceProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )

        #expect(proof == OpalHedgeFixtureData.contractStartingOracleProof)
    }

    @Test("Normalizes verified starting price proof hex")
    func normalizeVerifiedStartingPriceProofHex() throws {
        let proof = try OpalHedge.Oracle.verifyStartingPriceProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex.uppercased(),
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex.uppercased(),
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex.uppercased()
        )

        #expect(proof == OpalHedgeFixtureData.contractStartingOracleProof)
    }

    @Test("Normalizes verified starting price proof whitespace")
    func normalizeVerifiedStartingPriceProofWhitespace() throws {
        let proof = try OpalHedge.Oracle.verifyStartingPriceProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: " \(OpalHedgeFixtureData.startingOracleSignatureHex.uppercased())\n",
            publicKeyHex: "\n\(OpalHedgeFixtureData.oraclePublicKeyHex.uppercased()) "
        )

        #expect(proof == OpalHedgeFixtureData.contractStartingOracleProof)
    }

    @Test("Rejects invalid starting price signature")
    func rejectInvalidStartingPriceSignature() {
        let error = OpalHedgeTypedErrorCaptureTool.captureStartingPriceProofError {
            _ = try OpalHedge.Oracle.verifyStartingPriceProof(
                messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
                signatureHex: invalidSignatureHex,
                publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
            )
        }

        #expect(error == .invalidSignature)
    }

    private var invalidSignatureHex: String {
        let finalCharacter = OpalHedgeFixtureData.startingOracleSignatureHex.hasSuffix("0") ? "1" : "0"

        return String(OpalHedgeFixtureData.startingOracleSignatureHex.dropLast()) + finalCharacter
    }
}
