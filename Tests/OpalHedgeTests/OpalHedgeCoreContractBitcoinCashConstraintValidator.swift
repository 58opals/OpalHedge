// OpalHedgeCoreContractBitcoinCashConstraintValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractBitcoinCashConstraintValidator {
    @Test("Parses supported P2PKH payout address networks")
    func parseSupportedPayoutAddressNetworks() throws {
        let mainnetAddress = try OpalHedge.Core.ContractPayoutAddress(
            OpalHedgeFixtureData.shortPayoutAddress
        )
        let testnetAddress = try OpalHedge.Core.ContractPayoutAddress(
            OpalHedgeFixtureData.shortTestnetPayoutAddress
        )
        let regtestAddress = try OpalHedge.Core.ContractPayoutAddress(
            OpalHedgeFixtureData.shortRegtestPayoutAddress
        )
        let lockScript = try OpalHedge.Core.ContractLockScript(
            hex: OpalHedgeFixtureData.shortLockScriptHex
        )

        #expect(mainnetAddress.cashAddrPrefix == "bitcoincash")
        #expect(testnetAddress.cashAddrPrefix == "bchtest")
        #expect(regtestAddress.cashAddrPrefix == "bchreg")
        #expect(mainnetAddress.publicKeyHashHex == "285bb350881b21ac89724c6fb6dc914d096cd53b")
        #expect(testnetAddress.publicKeyHashHex == mainnetAddress.publicKeyHashHex)
        #expect(regtestAddress.publicKeyHashHex == mainnetAddress.publicKeyHashHex)
        #expect(lockScript.publicKeyHashHex == mainnetAddress.publicKeyHashHex)
    }

    @Test("Rejects unprefixed payout address")
    func rejectUnprefixedPayoutAddress() {
        let address = String(
            OpalHedgeFixtureData.shortPayoutAddress.dropFirst("bitcoincash:".count)
        )
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Core.ContractPayoutAddress(address)
        }

        #expect(
            error == .invalidPayoutAddress(
                name: "rawValue",
                value: "qq59hv6s3qdjrtyfwfxxldkuj9xsjmx48vrz882knz"
            )
        )
    }

    @Test("Rejects invalid payout address character")
    func rejectInvalidPayoutAddressCharacter() {
        let address = "bitcoincash:bq59hv6s3qdjrtyfwfxxldkuj9xsjmx48vrz882knz"
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Core.ContractPayoutAddress(address)
        }

        #expect(error == .invalidPayoutAddress(name: "rawValue", value: address))
    }

    @Test("Rejects payout address with invalid checksum")
    func rejectInvalidPayoutAddressChecksum() {
        let address = "bitcoincash:qq59hv6s3qdjrtyfwfxxldkuj9xsjmx48vrz882knp"
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Core.ContractPayoutAddress(address)
        }

        #expect(error == .invalidPayoutAddress(name: "rawValue", value: address))
    }

    @Test("Rejects unsupported payout address prefix")
    func rejectUnsupportedPayoutAddressPrefix() {
        let address = "simpleledger:qq59hv6s3qdjrtyfwfxxldkuj9xsjmx48vrz882knz"
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Core.ContractPayoutAddress(address)
        }

        #expect(error == .invalidPayoutAddress(name: "rawValue", value: address))
    }

    @Test("Rejects non-P2PKH payout address")
    func rejectNonPayToPublicKeyHashPayoutAddress() {
        let address = "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx"
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Core.ContractPayoutAddress(address)
        }

        #expect(error == .invalidPayoutAddress(name: "rawValue", value: address))
    }

    @Test("Rejects invalid lock script hex")
    func rejectInvalidLockScriptHex() {
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Core.ContractLockScript(hex: "zz")
        }

        #expect(error == .invalidLockScriptHex(name: "hex", value: "zz"))
    }

    @Test("Rejects unsupported lock script template")
    func rejectUnsupportedLockScriptTemplate() {
        let lockScriptHex = "76a914285bb350881b21ac89724c6fb6dc914d096cd53b88ad"
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Core.ContractLockScript(hex: lockScriptHex)
        }

        #expect(
            error == .unsupportedLockScriptTemplate(
                name: "hex",
                value: lockScriptHex
            )
        )
    }

    @Test("Rejects payout address and lock script drift")
    func rejectPayoutAddressAndLockScriptDrift() {
        let creationContext = OpalHedgeContractFixtureBuilder.makeCreationContext(
            shortPayoutAddress: OpalHedgeFixtureData.longPayoutAddress
        )
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateCreationContext(
                creationContext
            )
        }

        #expect(
            error == .inconsistentPayoutAddressLockScript(
                name: "shortPayoutAddress",
                addressPublicKeyHashHex: "45f1f1c4a9b9419a5088a3e9c24a293d7a150e64",
                lockScriptPublicKeyHashHex: "285bb350881b21ac89724c6fb6dc914d096cd53b"
            )
        )
    }

    @Test("Rejects payout address network mismatch at funding boundary")
    func rejectPayoutAddressNetworkMismatchAtFundingBoundary() {
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Client.Context().createAnyHedgeContractFundingRequest(
                from: OpalHedgeFixtureData.contractCreationContext,
                network: .regtest
            )
        }

        #expect(
            error == .inconsistentPayoutAddressNetwork(
                name: "shortPayoutAddress",
                expectedCashAddrPrefix: "bchreg",
                actualCashAddrPrefix: "bitcoincash"
            )
        )
    }
}
