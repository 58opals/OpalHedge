// OpalHedgeBitcoinCashAnyHedgeContractFundingOutput.swift

import OpalHedgeBitcoinCash

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
        guard payoutSatoshis > 0 else {
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

        self.contractAddress = contractAddress
        self.payoutSatoshis = payoutSatoshis
        self.dustReserveSatoshis = dustReserveSatoshis
        self.satoshis = totalSatoshis.partialValue
    }
}
