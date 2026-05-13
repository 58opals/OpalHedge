// OpalHedgeTypedErrorCaptureTool.swift

import Testing
import OpalHedge

enum OpalHedgeTypedErrorCaptureTool {
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

    static func captureContractDataDocumentError(
        _ operation: () throws -> Void
    ) -> OpalHedge.Core.ContractDataDocumentError? {
        do {
            try operation()
        } catch let error as OpalHedge.Core.ContractDataDocumentError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }

    static func captureSettlementOracleProofError(
        _ operation: () throws -> Void
    ) -> OpalHedge.Oracle.SettlementOracleProofError? {
        do {
            try operation()
        } catch let error as OpalHedge.Oracle.SettlementOracleProofError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }

    static func captureSettlementConditionError(
        _ operation: () throws -> Void
    ) -> OpalHedge.Core.SettlementConditionError? {
        do {
            try operation()
        } catch let error as OpalHedge.Core.SettlementConditionError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }

    static func captureSettlementCalculationError(
        _ operation: () throws -> Void
    ) -> OpalHedge.Core.SettlementCalculationError? {
        do {
            try operation()
        } catch let error as OpalHedge.Core.SettlementCalculationError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }

    static func captureFundingRecordError(
        _ operation: () throws -> Void
    ) -> OpalHedge.BitcoinCash.AnyHedgeContractFundingRecordError? {
        do {
            try operation()
        } catch let error as OpalHedge.BitcoinCash.AnyHedgeContractFundingRecordError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }
}
