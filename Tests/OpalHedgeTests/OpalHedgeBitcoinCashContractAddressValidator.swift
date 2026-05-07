// OpalHedgeBitcoinCashContractAddressValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeBitcoinCashContractAddressValidator {
    @Test("Derives mainnet P2SH CashAddr from script hash")
    func deriveMainnetPayToScriptHashCashAddrFromScriptHash() throws {
        let address = try OpalHedge.BitcoinCash.ContractAddress(
            scriptHash: Data([
                0x76, 0xa0, 0x40, 0x53, 0xbd, 0xa0, 0xa8, 0x8b,
                0xda, 0x51, 0x77, 0xb8, 0x6a, 0x15, 0xc3, 0xb2,
                0x9f, 0x55, 0x98, 0x73
            ]),
            network: .mainnet
        )

        #expect(address.rawValue == "bitcoincash:ppm2qsznhks23z7629mms6s4cwef74vcwvn0h829pq")
        #expect(address.network == .mainnet)
    }

    @Test("Derives testnet P2SH CashAddr from script hash")
    func deriveTestnetPayToScriptHashCashAddrFromScriptHash() throws {
        let address = try OpalHedge.BitcoinCash.ContractAddress(
            scriptHash: Data([
                0xf5, 0xbf, 0x48, 0xb3, 0x97, 0xda, 0xe7, 0x0b,
                0xe8, 0x2b, 0x3c, 0xca, 0x47, 0x93, 0xf8, 0xeb,
                0x2b, 0x6c, 0xda, 0xc9
            ]),
            network: .testnet
        )

        #expect(address.rawValue == "bchtest:pr6m7j9njldwwzlg9v7v53unlr4jkmx6eyvwc0uz5t")
        #expect(address.network == .testnet)
    }

    @Test("Derives contract address from redeem script hex")
    func deriveContractAddressFromRedeemScriptHex() throws {
        let address = try OpalHedge.BitcoinCash.ContractAddress(
            redeemScriptHex: "51",
            network: .regtest
        )
        let addressFromHash = try OpalHedge.BitcoinCash.ContractAddress(
            scriptHash: address.scriptHash,
            network: .regtest
        )

        #expect(address.rawValue == addressFromHash.rawValue)
        #expect(address.rawValue.hasPrefix("bchreg:p"))
    }

    @Test("Rejects invalid script hash length")
    func rejectInvalidScriptHashLength() {
        let error = captureContractAddressError {
            _ = try OpalHedge.BitcoinCash.ContractAddress(
                scriptHash: Data(repeating: 0, count: 19)
            )
        }

        #expect(error == .invalidScriptHashByteCount(19))
    }

    @Test("Rejects invalid redeem script hex")
    func rejectInvalidRedeemScriptHex() {
        let error = captureContractAddressError {
            _ = try OpalHedge.BitcoinCash.ContractAddress(
                redeemScriptHex: "zz"
            )
        }

        #expect(error == .invalidRedeemScriptHex("zz"))
    }

    private func captureContractAddressError(
        _ operation: () throws -> Void
    ) -> OpalHedge.BitcoinCash.ContractAddressError? {
        do {
            try operation()
        } catch let error as OpalHedge.BitcoinCash.ContractAddressError {
            return error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        return nil
    }
}
