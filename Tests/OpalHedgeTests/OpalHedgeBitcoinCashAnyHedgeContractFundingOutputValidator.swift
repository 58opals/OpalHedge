// OpalHedgeBitcoinCashAnyHedgeContractFundingOutputValidator.swift

import Testing
import OpalHedge

struct OpalHedgeBitcoinCashAnyHedgeContractFundingOutputValidator {
    @Test("Creates AnyHedge contract funding output")
    func createAnyHedgeContractFundingOutput() throws {
        let contractAddress = try OpalHedge.BitcoinCash.ContractAddress(
            redeemScriptHex: "51",
            network: .mainnet
        )
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
        let contractAddress = try OpalHedge.BitcoinCash.ContractAddress(
            redeemScriptHex: "51",
            network: .mainnet
        )
        let error = captureFundingOutputError {
            _ = try OpalHedge.BitcoinCash.AnyHedgeContractFundingOutput(
                contractAddress: contractAddress,
                payoutSatoshis: 0,
                dustReserveSatoshis: 1_332
            )
        }

        #expect(error == .invalidPayoutSatoshis(0))
    }

    @Test("Includes AnyHedge contract funding output in bundle")
    func includeAnyHedgeContractFundingOutputInBundle() throws {
        let bundle = try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
            plan: OpalHedge.Core.ContractPlan(
                from: OpalHedgeFixtureData.contractCreationContext
            )
        )

        #expect(bundle.fundingOutput.contractAddress == bundle.contractAddress)
        #expect(bundle.fundingOutput.payoutSatoshis == 5_649_717)
        #expect(bundle.fundingOutput.dustReserveSatoshis == 1_332)
        #expect(bundle.fundingOutput.satoshis == 5_651_049)
        #expect(
            bundle.fundingOutput.contractAddress.rawValue ==
                "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx"
        )
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
}
