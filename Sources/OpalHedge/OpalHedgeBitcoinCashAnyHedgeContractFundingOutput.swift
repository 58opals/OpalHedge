// OpalHedgeBitcoinCashAnyHedgeContractFundingOutput.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

public struct OpalHedgeBitcoinCashAnyHedgeContractFundingOutput: Sendable, Equatable {
    public let contractAddress: OpalHedgeBitcoinCashContractAddress
    public let payoutSatoshis: Int64
    public let dustReserveSatoshis: Int64
    public let satoshis: Int64

    public init(
        contractAddress: OpalHedgeBitcoinCashContractAddress,
        payoutSatoshis: Int64,
        dustReserveSatoshis: Int64
    ) throws {
        guard payoutSatoshis >= OpalHedgeCoreContractConstraintPolicy.dustLimitSatoshis else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError
                .invalidPayoutSatoshis(payoutSatoshis)
        }
        guard dustReserveSatoshis >= 0 else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError
                .invalidDustReserveSatoshis(dustReserveSatoshis)
        }

        let totalSatoshis = payoutSatoshis.addingReportingOverflow(
            dustReserveSatoshis
        )
        guard !totalSatoshis.overflow else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError
                .fundingSatoshisOverflow(
                    payoutSatoshis: payoutSatoshis,
                    dustReserveSatoshis: dustReserveSatoshis
                )
        }
        guard totalSatoshis.partialValue <=
              OpalHedgeCoreContractConstraintPolicy.maxContractSatoshis else {
            throw OpalHedgeBitcoinCashAnyHedgeContractFundingOutputError
                .invalidPayoutSatoshis(payoutSatoshis)
        }

        self.contractAddress = contractAddress
        self.payoutSatoshis = payoutSatoshis
        self.dustReserveSatoshis = dustReserveSatoshis
        self.satoshis = totalSatoshis.partialValue
    }
}
