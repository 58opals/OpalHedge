// OpalHedgeCoreContractPayoutAddress.swift

public struct OpalHedgeCoreContractPayoutAddress: Sendable, Equatable {
    public let rawValue: String
    public let cashAddrPrefix: String
    public let publicKeyHashHex: String

    public init(_ rawValue: String) throws {
        let cashAddr = try OpalHedgeCoreContractConstraintEvaluator.validatePayoutAddress(
            rawValue,
            name: "rawValue"
        )

        self.rawValue = rawValue
        self.cashAddrPrefix = cashAddr.cashAddrPrefix
        self.publicKeyHashHex = cashAddr.publicKeyHashHex
    }
}
