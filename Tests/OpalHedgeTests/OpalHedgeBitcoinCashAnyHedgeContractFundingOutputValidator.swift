// OpalHedgeBitcoinCashAnyHedgeContractFundingOutputValidator.swift

import Testing
import OpalHedge
import OpalHedgeBitcoinCash

struct OpalHedgeBitcoinCashAnyHedgeContractFundingOutputValidator {
    @Test("Creates AnyHedge contract funding output")
    func createAnyHedgeContractFundingOutput() throws {
        let contractAddress = try makeContractAddress()
        let fundingOutput = try OpalHedge.BitcoinCash
            .AnyHedgeContractFundingOutput(
                contractAddress: contractAddress,
                payoutSatoshis: 5_649_717,
                dustReserveSatoshis: 1_332
            )

        #expect(fundingOutput.contractAddress == contractAddress)
        #expect(fundingOutput.payoutSatoshis == 5_649_717)
        #expect(fundingOutput.dustReserveSatoshis == 1_332)
        #expect(fundingOutput.satoshis == 5_651_049)
    }

    @Test("Rejects invalid AnyHedge contract funding output satoshis")
    func rejectInvalidAnyHedgeContractFundingOutputSatoshis() throws {
        let contractAddress = try makeContractAddress()
        let error = try #require(captureFundingOutputError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractFundingOutput(
                contractAddress: contractAddress,
                payoutSatoshis: 1,
                dustReserveSatoshis: 1_332
            )
        })

        #expect(error == .invalidPayoutSatoshis(1))
    }

    @Test("Rejects oversized AnyHedge contract funding output satoshis")
    func rejectOversizedAnyHedgeContractFundingOutputSatoshis() throws {
        let contractAddress = try makeContractAddress()
        let maximumContractSatoshis = OpalHedge.Core.ContractConstraintPolicy
            .maxContractSatoshis
        let error = try #require(captureFundingOutputError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractFundingOutput(
                contractAddress: contractAddress,
                payoutSatoshis: maximumContractSatoshis,
                dustReserveSatoshis: 1
            )
        })

        #expect(error == .invalidPayoutSatoshis(maximumContractSatoshis))
    }

    private func captureFundingOutputError(
        _ operation: () throws -> Void
    ) -> OpalHedge.BitcoinCash.AnyHedgeContractFundingOutputError? {
        do {
            try operation()
        } catch let error as OpalHedge.BitcoinCash.AnyHedgeContractFundingOutputError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }

    private func makeContractAddress() throws -> OpalHedgeBitcoinCashContractAddress {
        try OpalHedgeBitcoinCashContractAddress(
            rawRedeemScriptHex: "51",
            network: .mainnet
        )
    }
}
