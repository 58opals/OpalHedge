// OpalHedgeCoreContractConstraintEvaluator~BitcoinCash.swift

extension OpalHedgeCoreContractConstraintEvaluator {
    static func validatePayoutAddress(
        _ value: String,
        name: String
    ) throws -> OpalHedgeCoreCashAddrPayoutAddress {
        try OpalHedgeCoreCashAddrPayoutAddress.parse(value, name: name)
    }

    static func validateLockScriptHex(_ value: String, name: String) throws {
        let expectedScriptLength = OpalHedgeCoreContractConstraintPolicy
            .payToPublicKeyHashLockScriptHexCharacterCount
        let lockScriptPrefix = OpalHedgeCoreContractConstraintPolicy
            .payToPublicKeyHashLockScriptPrefixHex
        let lockScriptSuffix = OpalHedgeCoreContractConstraintPolicy
            .payToPublicKeyHashLockScriptSuffixHex

        guard value.count == expectedScriptLength,
              value.allSatisfy({ lowercaseHexCharacters.contains($0) }) else {
            throw OpalHedgeCoreContractConstraintError.invalidLockScriptHex(
                name: name,
                value: value
            )
        }

        guard value.hasPrefix(lockScriptPrefix),
              value.hasSuffix(lockScriptSuffix) else {
            throw OpalHedgeCoreContractConstraintError.unsupportedLockScriptTemplate(
                name: name,
                value: value
            )
        }
    }

    private static var lowercaseHexCharacters: String {
        "0123456789abcdef"
    }
}
