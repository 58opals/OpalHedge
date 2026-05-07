// OpalHedgeBitcoinCashContractScriptArtifact.swift

public struct OpalHedgeBitcoinCashContractScriptArtifact: Sendable, Equatable {
    public let version: OpalHedgeBitcoinCashContractScriptArtifactVersion
    public let packageName: String
    public let sourceCodeUrl: String
    public let bytecodeAssemblyUrl: String
    public let artifactJsonUrl: String

    public init(
        version: OpalHedgeBitcoinCashContractScriptArtifactVersion,
        packageName: String,
        sourceCodeUrl: String,
        bytecodeAssemblyUrl: String,
        artifactJsonUrl: String
    ) {
        self.version = version
        self.packageName = packageName
        self.sourceCodeUrl = sourceCodeUrl
        self.bytecodeAssemblyUrl = bytecodeAssemblyUrl
        self.artifactJsonUrl = artifactJsonUrl
    }

    public static let anyHedgeV0_12 = Self(
        version: .anyHedgeV0_12,
        packageName: "@generalprotocols/anyhedge-contracts",
        sourceCodeUrl: "https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/raw/development/contracts/v0.12/contract.cash",
        bytecodeAssemblyUrl: "https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/raw/development/contracts/v0.12/bytecode.asm",
        artifactJsonUrl: "https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/raw/development/contracts/v0.12/artifact.json"
    )
}
