// OpalHedgeOracleSignatureVerifierValidator.swift

import Testing
import OpalHedge

struct OpalHedgeOracleSignatureVerifierValidator {
    @Test("Verifies upstream starting oracle signature")
    func verifyUpstreamStartingOracleSignature() throws {
        let message = try OpalHedge.Oracle.PriceMessage.parse(
            hex: OpalHedgeFixtureData.startingOracleMessageHex
        )

        let isValid = try OpalHedge.Oracle.SignatureVerifier.verify(
            message: message,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )

        #expect(isValid)
    }
}
