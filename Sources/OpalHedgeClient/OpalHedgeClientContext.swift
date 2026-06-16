// OpalHedgeClientContext.swift

public struct OpalHedgeClientContext: Sendable {
    public let domainAuthority: OpalHedgeClientDomainAuthority

    public init(
        domainAuthority: OpalHedgeClientDomainAuthority = .contractOracleAuthoringDomain
    ) {
        self.domainAuthority = domainAuthority
    }
}
