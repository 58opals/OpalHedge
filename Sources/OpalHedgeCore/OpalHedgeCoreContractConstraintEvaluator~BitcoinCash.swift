// OpalHedgeCoreContractConstraintEvaluator~BitcoinCash.swift

extension OpalHedgeCoreContractConstraintEvaluator {
    static func validatePayoutAddress(_ value: String, name: String) throws {
        let prefix = OpalHedgeCoreContractConstraintPolicy.cashAddressPrefix
        let expectedPayloadLength = OpalHedgeCoreContractConstraintPolicy
            .cashAddressPayToPublicKeyHashPayloadLength
        let payload = value.dropFirst(prefix.count)

        guard value.hasPrefix(prefix),
              value == value.lowercased(),
              payload.count == expectedPayloadLength,
              payload.allSatisfy({ cashAddressPayloadCharacters.contains($0) }) else {
            throw OpalHedgeCoreContractConstraintError.invalidPayoutAddress(
                name: name,
                value: value
            )
        }
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

    private static var cashAddressPayloadCharacters: String {
        "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
    }

    private static var lowercaseHexCharacters: String {
        "0123456789abcdef"
    }
}
