// OpalHedgeOraclePriceMessageValidator.swift

import Testing
import OpalHedge

struct OpalHedgeOraclePriceMessageValidator {
    @Test("Parses upstream AnyHedge starting oracle price message")
    func parseUpstreamStartingPriceMessage() throws {
        let message = try OpalHedge.Oracle.PriceMessage.parse(
            hex: OpalHedgeFixtureData.startingOracleMessageHex
        )

        #expect(message.messageTimestamp == 615_643)
        #expect(message.messageSequence == 1)
        #expect(message.priceSequence == 1)
        #expect(message.priceValue == 23_600)
        #expect(message.hex == OpalHedgeFixtureData.startingOracleMessageHex)
    }

    @Test("Rejects wrong price message length")
    func rejectWrongPriceMessageLength() {
        var didThrow = false

        do {
            _ = try OpalHedge.Oracle.PriceMessage.parse(hex: "00")
        } catch {
            didThrow = true
        }

        #expect(didThrow)
    }

    @Test("Rejects metadata sequence as a price message")
    func rejectMetadataSequenceAsPriceMessage() {
        var didThrow = false

        do {
            _ = try OpalHedge.Oracle.PriceMessage.parse(hex: "0100000001000000ffffffff01000000")
        } catch {
            didThrow = true
        }

        #expect(didThrow)
    }
}
