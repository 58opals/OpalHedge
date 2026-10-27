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
    static let libraryRevision = "bf87e6769abe8030b217fa00b4c346695dbd8055"
    static let tenWeekSourceSHA256 =
        "f5a514662f954ea9d47addace923a7e3ef43858697e6980674e95c084e8675ff"
    static let tenWeekParametersSHA256 =
        "cf3b0fe267a258d653015875a3d98dfa2a1b136c8516ca3f2e3270df64964a52"
    static let tenWeekOracleProofSHA256 =
        "7ca40c8cabedd452386b508a12a01c4ba965a2e5975c983f3fa01944426c8a5a"
}
