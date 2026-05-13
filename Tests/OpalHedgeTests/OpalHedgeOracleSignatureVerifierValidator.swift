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

    @Test("Rejects non-canonical oracle price message fields")
    func rejectNonCanonicalOraclePriceMessageFields() throws {
        let message = try OpalHedge.Oracle.PriceMessage.parse(
            hex: OpalHedgeFixtureData.startingOracleMessageHex
        )
        let nonCanonicalMessage = OpalHedge.Oracle.PriceMessage(
            rawData: message.rawData,
            messageTimestamp: message.messageTimestamp,
            messageSequence: message.messageSequence,
            priceSequence: message.priceSequence,
            priceValue: message.priceValue + 1
        )

        let isValid = try OpalHedge.Oracle.SignatureVerifier.verify(
            message: nonCanonicalMessage,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )

        #expect(!isValid)
    }
}
