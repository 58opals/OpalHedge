// OpalHedgeBitcoinCashNetwork+Core.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

extension OpalHedgeBitcoinCashNetwork {
    package func validatePayoutAddressNetworks(
        in plan: OpalHedgeCoreContractPlan
    ) throws {
        try validatePayoutAddressNetworks(in: plan.metadata)
    }

    package func validatePayoutAddressNetworks(
        in draftData: OpalHedgeCoreContractDraftData
    ) throws {
        try validatePayoutAddressNetworks(in: draftData.metadata)
        try validateFeeAddressNetworks(in: draftData.fees)
    }

    private func validatePayoutAddressNetworks(
        in metadata: OpalHedgeCoreContractMetadata
    ) throws {
        try validate(metadata.shortPayoutAddress, name: "shortPayoutAddress")
        try validate(metadata.longPayoutAddress, name: "longPayoutAddress")
    }

    private func validate(
        _ address: OpalHedgeCoreContractPayoutAddress,
        name: String
    ) throws {
        guard address.cashAddrPrefix == cashAddrPrefix else {
            throw OpalHedgeCoreContractConstraintError
                .inconsistentPayoutAddressNetwork(
                    name: name,
                    expectedCashAddrPrefix: cashAddrPrefix,
                    actualCashAddrPrefix: address.cashAddrPrefix
                )
        }
    }

    private func validateFeeAddressNetworks(
        in fees: [OpalHedgeCoreContractFeeData]
    ) throws {
        for (index, fee) in fees.enumerated() {
            try validate(
                OpalHedgeCoreContractPayoutAddress(fee.address),
                name: "fees[\(index)].address"
            )
        }
    }
}
