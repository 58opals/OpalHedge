// OpalHedgeCoreContractBitcoinCashConstraintValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractBitcoinCashConstraintValidator {
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
}
