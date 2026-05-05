// OpalHedgeCoreContractPayoutAddress.swift

public struct OpalHedgeCoreContractPayoutAddress: Sendable, Equatable {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try OpalHedgeCoreContractConstraintEvaluator.validatePayoutAddress(
            rawValue,
            name: "rawValue"
        )

        self.rawValue = rawValue
    }
}
