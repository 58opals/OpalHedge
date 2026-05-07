// OpalHedgeCoreContractLockScript.swift

public struct OpalHedgeCoreContractLockScript: Sendable, Equatable {
    public let hex: String
    public let publicKeyHashHex: String

    public init(hex: String) throws {
        try OpalHedgeCoreContractConstraintEvaluator.validateLockScriptHex(
            hex,
            name: "hex"
        )

        self.hex = hex
        self.publicKeyHashHex = String(
            hex
                .dropFirst(OpalHedgeCoreContractConstraintPolicy
                    .payToPublicKeyHashLockScriptPrefixHex.count)
                .dropLast(OpalHedgeCoreContractConstraintPolicy
                    .payToPublicKeyHashLockScriptSuffixHex.count)
        )
    }
}
