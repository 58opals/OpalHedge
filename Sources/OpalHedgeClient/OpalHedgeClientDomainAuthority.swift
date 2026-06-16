// OpalHedgeClientDomainAuthority.swift

public struct OpalHedgeClientDomainAuthority: Sendable, Equatable {
    public let supportsWalletAssetInteractorLane: Bool
    public let supportsClaimableInteractorLane: Bool
    public let supportsExplicitAuthoringWorkflowLane: Bool
    public let ownsWalletRuntime: Bool
    public let ownsSecretAccess: Bool
    public let ownsPublicChainTransport: Bool
    public let ownsSwiftDataSnapshots: Bool
    public let ownsTransactionBroadcast: Bool
    public let ownsUserTriggeredMoneyMovement: Bool

    public static let contractOracleAuthoringDomain = Self(
        supportsWalletAssetInteractorLane: true,
        supportsClaimableInteractorLane: true,
        supportsExplicitAuthoringWorkflowLane: true,
        ownsWalletRuntime: false,
        ownsSecretAccess: false,
        ownsPublicChainTransport: false,
        ownsSwiftDataSnapshots: false,
        ownsTransactionBroadcast: false,
        ownsUserTriggeredMoneyMovement: false
    )
}
