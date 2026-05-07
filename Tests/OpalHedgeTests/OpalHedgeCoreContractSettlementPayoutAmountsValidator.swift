// OpalHedgeCoreContractSettlementPayoutAmountsValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractSettlementPayoutAmountsValidator {
    @Test("Creates contract settlement payout amounts")
    func createContractSettlementPayoutAmounts() {
        let payoutAmounts = OpalHedge.Core.ContractSettlementPayoutAmounts(
            shortPayoutInSatoshis: 4_255_319,
            longPayoutInSatoshis: 1_394_398
        )

        #expect(payoutAmounts.shortPayoutInSatoshis == 4_255_319)
        #expect(payoutAmounts.longPayoutInSatoshis == 1_394_398)
        #expect(payoutAmounts.totalPayoutInSatoshis == 5_649_717)
    }
}
