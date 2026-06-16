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
