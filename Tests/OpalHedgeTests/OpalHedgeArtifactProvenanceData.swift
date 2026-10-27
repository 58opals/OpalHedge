// OpalHedgeArtifactProvenanceData.swift

/// Reviewed byte identities, independent of the constructor and script implementation.
/// See Docs/AnyHedgeProvenance.md for the source and the limits of this comparison.
enum OpalHedgeArtifactProvenanceData {
    static let upstreamRevision = "9505f738486becfc297d42d91c4fc4685bec7a14"
    static let upstreamArtifactSHA256 =
        "bc7dd9fdaba43fc97250dc74f59a24701d18a235d7f875ad880a6b6120c740fb"
    static let programSHA256 =
        "74418e6a1ca246ea9142f026d6a39a0683f0af0074b29c7fded89d3bdf723de6"

    // This is the existing local ten-week fixture, not a claimed upstream compiler result.
    static let tenWeekConstructorSHA256 =
        "1a52b2ea89aa5781ff14e52f56640543bb4ee210b378651f0540c7fa2abb4acd"
}
