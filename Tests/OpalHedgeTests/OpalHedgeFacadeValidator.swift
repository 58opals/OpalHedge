// OpalHedgeFacadeValidator.swift

import Testing
import OpalHedge

struct OpalHedgeFacadeValidator {
    @Test("Creates facade contexts")
    func createFacadeContexts() {
        _ = OpalHedge.Core.Context()
        _ = OpalHedge.Oracle.Context()
        _ = OpalHedge.BitcoinCash.Context()
        _ = OpalHedge.Client.Context()
    }

    @Test("Uses facade aliases")
    func useFacadeAliases() throws {
        let message = try OpalHedge.Oracle.PriceMessage.parse(
            hex: OpalHedgeFixtureData.startingOracleMessageHex
        )
        let outcome = try OpalHedge.Core.SettlementCalculator.calculateOutcome(
            parameters: OpalHedgeFixtureData.contractParameters,
            fundingSatoshis: 5_651_049,
            redeemPrice: message.priceValue
        )

        #expect(outcome.shortPayoutSatsSafe == 4_237_288)
    }
}
