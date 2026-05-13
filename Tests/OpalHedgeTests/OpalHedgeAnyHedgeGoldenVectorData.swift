// OpalHedgeAnyHedgeGoldenVectorData.swift

enum OpalHedgeAnyHedgeGoldenVectorData {
    static let sourceReferences = [
        OpalHedgeFixtureSourceReferenceData(
            family: .anyHedgeContractMetadata,
            title: "AnyHedge ContractMetadataV1 interface",
            url: OpalHedgeFixtureReferenceData.anyHedgeContractMetadataV1Url,
            coveredFixtureNames: [
                upstreamHedgeTenWeekContractMetadataFixtureName
            ]
        ),
        OpalHedgeFixtureSourceReferenceData(
            family: .anyHedgeContractFunding,
            title: "AnyHedge ContractFundingV1 interface",
            url: OpalHedgeFixtureReferenceData.anyHedgeContractFundingV1Url,
            coveredFixtureNames: [
                upstreamHedgeTenWeekContractFundingsFixtureName
            ]
        ),
        OpalHedgeFixtureSourceReferenceData(
            family: .anyHedgeContractAutomatedPayout,
            title: "AnyHedge ContractAutomatedPayoutV1 interface",
            url: OpalHedgeFixtureReferenceData.anyHedgeContractAutomatedPayoutV1Url,
            coveredFixtureNames: [
                upstreamHedgeTenWeekContractSettlementFixtureName
            ]
        ),
        OpalHedgeFixtureSourceReferenceData(
            family: .priceOracle,
            title: "PriceOracle library",
            url: OpalHedgeFixtureReferenceData.priceOracleLibraryUrl,
            coveredFixtureNames: [
                "oraclePublicKeyHex",
                "startingOracleMessageHex",
                "startingOracleSignatureHex"
            ]
        )
    ]

    static let sourceUrls = sourceReferences.map(\.url)
    static let upstreamHedgeTenWeekContractDataDocumentFixtureName =
        "upstreamHedgeTenWeekContractDataDocumentJsonText"
    static let upstreamHedgeTenWeekContractMetadataFixtureName =
        upstreamHedgeTenWeekContractDataDocumentFixtureName + ".metadata"
    static let upstreamHedgeTenWeekContractFundingsFixtureName =
        upstreamHedgeTenWeekContractDataDocumentFixtureName + ".fundings"
    static let upstreamHedgeTenWeekContractSettlementFixtureName =
        upstreamHedgeTenWeekContractDataDocumentFixtureName + ".fundings.settlement"
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
