// OpalHedgeAnyHedgeGoldenVectorData.swift

enum OpalHedgeAnyHedgeGoldenVectorData {
    static let sourceReferences = [
        OpalHedgeFixtureReferenceData.anyHedgeContractMetadataV1Url,
        OpalHedgeFixtureReferenceData.anyHedgeContractFundingV1Url,
        OpalHedgeFixtureReferenceData.anyHedgeContractAutomatedPayoutV1Url,
        OpalHedgeFixtureReferenceData.priceOracleLibraryUrl
    ]

    static let constructorStackPushHexTexts = [
        "03dbad65",
        "03db6409",
        "03e09903",
        "022445",
        "03353556",
        "00",
        "0500e8764817",
        "21" + OpalHedgeFixtureData.oraclePublicKeyHex,
        "19" + OpalHedgeFixtureData.longLockScriptHex,
        "19" + OpalHedgeFixtureData.shortLockScriptHex,
        "51",
        "21" + OpalHedgeFixtureData.longMutualRedeemPublicKeyHex,
        "21" + OpalHedgeFixtureData.shortMutualRedeemPublicKeyHex
    ]

    static let constructorStackBytecodeHex = constructorStackPushHexTexts.joined()
    static let constructorStackPushCount = 13
    static let constructorStackBytecodeByteCount = 181
    static let redeemScriptBytecodeByteCount = 343
    static let contractScriptBytecodeSuffixHex = "cd547a8777777768"
    static let mainnetContractScriptHashHex = "6cf774143b35046148a90f3f9024b2fd96541e5c"
    static let mainnetContractAddress = "bitcoincash:ppk0waq58v6sgc2g4y8nlypykt7ev4q7tsa5nzzwvx"
    static let payoutSatoshis: Int64 = 5_649_717
    static let dustReserveSatoshis: Int64 = 1_332
    static let fundingOutputSatoshis: Int64 = 5_651_049
    static let contractDataDocumentJsonText =
        OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
}
