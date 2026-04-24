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
}
