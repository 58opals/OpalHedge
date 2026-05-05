// OpalHedgeCoreContractLockScript.swift

public struct OpalHedgeCoreContractLockScript: Sendable, Equatable {
    public let hex: String

    public init(hex: String) throws {
        try OpalHedgeCoreContractConstraintEvaluator.validateLockScriptHex(
            hex,
            name: "hex"
        )

        self.hex = hex
    }
}
