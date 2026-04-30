// OpalHedgeCoreContractPresetValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractPresetValidator {
    @Test("Provides USD simple hedge thirty day defaults")
    func provideUSDSimpleHedgeThirtyDayDefaults() {
        let preset = OpalHedge.Core.ContractPreset.usdSimpleHedgeThirtyDay

        #expect(preset.unitCode == "USD")
        #expect(preset.side == .short)
        #expect(preset.durationInSeconds == 2_592_000)
        #expect(preset.isSimpleHedge == 1)
        #expect(preset.lowLiquidationPriceMultiplier == 0.75)
        #expect(preset.highLiquidationPriceMultiplier == 10.0)
    }
}
