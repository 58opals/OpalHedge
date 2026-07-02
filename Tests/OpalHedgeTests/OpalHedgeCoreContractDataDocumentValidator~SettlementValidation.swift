// OpalHedgeCoreContractDataDocumentValidator~SettlementValidation.swift

import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentValidator {
    @Test("Rejects invalid settlement transaction hash when creating contract data document")
    func rejectInvalidSettlementTransactionHashWhenCreatingContractDataDocument() throws {
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: .maturation,
            settlementTransactionHash: "zz",
            shortPayoutInSatoshis: 4_237_288,
            longPayoutInSatoshis: 1_412_429
        )
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049,
                    settlement: settlement
                )
            ]
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        }

        #expect(
            error == .invalidTransactionHashHex(
                name: "fundings[0].settlement.settlementTransactionHash",
                value: "zz"
            )
        )
    }

    @Test("Rejects sub-dust settlement payout satoshis when creating contract data document")
    func rejectSubDustSettlementPayoutSatoshisWhenCreatingContractDataDocument() throws {
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: .maturation,
            settlementTransactionHash: String(repeating: "2", count: 64),
            shortPayoutInSatoshis: OpalHedge.Core.ContractConstraintPolicy
                .dustLimitSatoshis - 1,
            longPayoutInSatoshis: 1_412_429
        )
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049,
                    settlement: settlement
                )
            ]
        )
        let error = try #require(OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        })

        #expect(
            error == .invalidPayoutSatoshis(
                OpalHedge.Core.ContractConstraintPolicy.dustLimitSatoshis - 1
            )
        )
    }

    @Test("Rejects negative settlement price when creating contract data document")
    func rejectNegativeSettlementPriceWhenCreatingContractDataDocument() throws {
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: .maturation,
            settlementTransactionHash: String(repeating: "2", count: 64),
            shortPayoutInSatoshis: 4_237_288,
            longPayoutInSatoshis: 1_412_429,
            settlementPrice: -1
        )
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049,
                    settlement: settlement
                )
            ]
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        }

        #expect(
            error == .invalidPositiveInteger(
                name: "fundings[0].settlement.settlementPrice",
                value: -1
            )
        )
    }

    @Test("Rejects invalid settlement oracle message hex when creating contract data document")
    func rejectInvalidSettlementOracleMessageHexWhenCreatingContractDataDocument() throws {
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: .maturation,
            settlementTransactionHash: String(repeating: "2", count: 64),
            shortPayoutInSatoshis: 4_237_288,
            longPayoutInSatoshis: 1_412_429,
            settlementMessageHex: "zz"
        )
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049,
                    settlement: settlement
                )
            ]
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        }

        #expect(
            error == .invalidOracleMessageHex(
                name: "fundings[0].settlement.settlementMessage",
                value: "zz"
            )
        )
    }

    @Test("Rejects excessive settlement payout total when creating contract data document")
    func rejectExcessiveSettlementPayoutTotalWhenCreatingContractDataDocument() throws {
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: .maturation,
            settlementTransactionHash: String(repeating: "2", count: 64),
            shortPayoutInSatoshis: OpalHedge.Core.ContractConstraintPolicy
                .maxContractSatoshis,
            longPayoutInSatoshis: OpalHedge.Core.ContractConstraintPolicy
                .dustLimitSatoshis
        )
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049,
                    settlement: settlement
                )
            ]
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        }

        #expect(
            error == .contractSatoshisExceedMaximum(
                OpalHedge.Core.ContractConstraintPolicy.maxContractSatoshis
                    + OpalHedge.Core.ContractConstraintPolicy.dustLimitSatoshis
            )
        )
    }

    @Test("Rejects settlement payout total above funding when creating contract data document")
    func rejectSettlementPayoutTotalAboveFundingWhenCreatingContractDataDocument() throws {
        let settlement = OpalHedge.Core.ContractSettlement(
            kind: .maturation,
            settlementTransactionHash: String(repeating: "2", count: 64),
            shortPayoutInSatoshis: 4_237_288,
            longPayoutInSatoshis: 1_412_430
        )
        let draftData = try makeDraftData(
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_649_717,
                    settlement: settlement
                )
            ]
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractDataDocument(draftData: draftData)
        }

        #expect(
            error == .invalidContractFunding(
                shortInput: 4_237_288,
                longInput: 1_412_430,
                payoutSats: 5_649_717
            )
        )
    }
}
