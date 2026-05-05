// OpalHedgeCoreContractOracleSignature.swift

public struct OpalHedgeCoreContractOracleSignature: Sendable, Equatable {
    public let hex: String

    public init(hex: String) throws {
        try self.init(hex: hex, name: "hex")
    }

    package init(hex: String, name: String) throws {
        try OpalHedgeCoreContractConstraintEvaluator.validateSchnorrSignatureHex(
            hex,
            name: name
        )

        self.hex = hex
    }
}
