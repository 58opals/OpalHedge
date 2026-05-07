// OpalHedgeBitcoinCashContractScriptArtifactVersion.swift

public struct OpalHedgeBitcoinCashContractScriptArtifactVersion: Sendable, Equatable {
    public let rawValue: String
    public let displayName: String
    public let contractDirectoryPath: String

    public init(
        rawValue: String,
        displayName: String,
        contractDirectoryPath: String
    ) {
        self.rawValue = rawValue
        self.displayName = displayName
        self.contractDirectoryPath = contractDirectoryPath
    }

    public static let anyHedgeV0_12 = Self(
        rawValue: "v0.12",
        displayName: "AnyHedge v0.12",
        contractDirectoryPath: "contracts/v0.12"
    )
}
