// OpalHedgeOraclePriceMessageValidator.swift

import Testing
import OpalHedge

struct OpalHedgeOraclePriceMessageValidator {
    @Test("Parses upstream AnyHedge starting oracle price message")
    func parseUpstreamStartingPriceMessage() throws {
        let message = try OpalHedge.Oracle.PriceMessage.parse(
            rawHex: OpalHedgeFixtureData.startingOracleMessageHex
        )

        #expect(message.messageTimestamp == 615_643)
        #expect(message.messageSequence == 1)
        #expect(message.priceSequence == 1)
        #expect(message.priceValue == 23_600)
        #expect(message.rawMessageHex == OpalHedgeFixtureData.startingOracleMessageHex)
    }

    @Test("Rejects wrong price message length")
    func rejectWrongPriceMessageLength() {
        var didThrow = false

        do {
            _ = try OpalHedge.Oracle.PriceMessage.parse(rawHex: "00")
        } catch {
            didThrow = true
        }

        #expect(didThrow)
    }

    @Test(
        "Rejects signed integer chunks in oracle hexadecimal text",
        arguments: [
            ("+1000000010000000100000001000000", "+1"),
            ("01-00000010000000100000001000000", "-0"),
            ("010000000100000001000000+f000000", "+f")
        ]
    )
    func rejectSignedIntegerHexadecimalChunks(_ malformedHex: String, _ invalidChunk: String) {
        #expect(throws: OpalHedge.Oracle.MessageError.invalidHexCharacter(invalidChunk)) {
            _ = try OpalHedge.Oracle.PriceMessage.parse(rawHex: malformedHex)
        }
    }

    @Test("Parses oracle hexadecimal text with uppercase digits and surrounding whitespace")
    func parseUppercaseHexadecimalWithSurroundingWhitespace() throws {
        let message = try OpalHedge.Oracle.PriceMessage.parse(
            rawHex: " \n" + OpalHedgeFixtureData.startingOracleMessageHex.uppercased() + "\t "
        )

        #expect(message.rawMessageHex == OpalHedgeFixtureData.startingOracleMessageHex)
    }

    @Test("Rejects metadata sequence as a price message")
    func rejectMetadataSequenceAsPriceMessage() {
        var didThrow = false

        do {
            _ = try OpalHedge.Oracle.PriceMessage.parse(rawHex: "0100000001000000ffffffff01000000")
        } catch {
            didThrow = true
        }

        #expect(didThrow)
    }

    @Test("Parses maximum positive script integer fields")
    func parseMaximumPositiveScriptIntegerFields() throws {
        let message = try OpalHedge.Oracle.PriceMessage.parse(
            rawHex: "ffffff7fffffff7fffffff7fffffff7f"
        )

        #expect(message.messageTimestamp == 2_147_483_647)
        #expect(message.messageSequence == 2_147_483_647)
        #expect(message.priceSequence == 2_147_483_647)
        #expect(message.priceValue == 2_147_483_647)
    }
}
