// OpalHedgeTypedErrorCapture.swift

import Testing
import OpalHedge

enum OpalHedgeTypedErrorCapture {
    static func captureConstraintError(
        _ operation: () throws -> Void
    ) -> OpalHedge.Core.ContractConstraintError? {
        do {
            try operation()
        } catch let error as OpalHedge.Core.ContractConstraintError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }

    static func captureStartingPriceProofError(
        _ operation: () throws -> Void
    ) -> OpalHedge.Oracle.StartingPriceProofError? {
        do {
            try operation()
        } catch let error as OpalHedge.Oracle.StartingPriceProofError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }
}
