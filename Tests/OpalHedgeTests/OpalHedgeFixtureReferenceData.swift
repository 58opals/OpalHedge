// OpalHedgeFixtureReferenceData.swift

enum OpalHedgeFixtureReferenceData {
    static let anyHedgeContractMetadataV1Url =
        "https://generalprotocols.gitlab.io/anyhedge/library/interfaces/ContractMetadataV1.html"
    static let anyHedgeContractFundingV1Url =
        "https://generalprotocols.gitlab.io/anyhedge/library/interfaces/ContractFundingV1.html"
    static let anyHedgeContractAutomatedPayoutV1Url =
        "https://generalprotocols.gitlab.io/anyhedge/library/interfaces/ContractAutomatedPayoutV1.html"
    static let priceOracleLibraryUrl =
        "https://generalprotocols.gitlab.io/priceoracle/library"

    static let anyHedgeContractDataDocumentFieldNames: Set<String> = [
        "fees",
        "fundings",
        "metadata",
        "parameters"
    ]

    static let anyHedgeContractMetadataV1FieldNames: Set<String> = [
        "durationInSeconds",
        "hedgeInputInOracleUnits",
        "hedgeInputInSatoshis",
        "hedgePayoutAddress",
        "highLiquidationPriceMultiplier",
        "longInputInOracleUnits",
        "longInputInSatoshis",
        "longPayoutAddress",
        "lowLiquidationPriceMultiplier",
        "makerSide",
        "minerCostInSatoshis",
        "nominalUnits",
        "startPrice",
        "startingOracleMessage",
        "startingOracleSignature",
        "takerSide"
    ]

    static let anyHedgeContractParametersV1FieldNames: Set<String> = [
        "enableMutualRedemption",
        "hedgeLockScript",
        "hedgeMutualRedeemPublicKey",
        "highLiquidationPrice",
        "longLockScript",
        "longMutualRedeemPublicKey",
        "lowLiquidationPrice",
        "maturityTimestamp",
        "nominalUnitsXSatsPerBch",
        "oraclePublicKey",
        "payoutSats",
        "satsForNominalUnitsAtHighLiquidation",
        "startTimestamp"
    ]

    static let anyHedgeContractFundingV1FieldNames: Set<String> = [
        "fundingOutputIndex",
        "fundingSatoshis",
        "fundingTransactionHash"
    ]

    static let anyHedgeContractFundingWithSettlementV1FieldNames =
        anyHedgeContractFundingV1FieldNames.union(["settlement"])

    static let anyHedgeContractAutomatedPayoutV1FieldNames: Set<String> = [
        "hedgePayoutInSatoshis",
        "longPayoutInSatoshis",
        "previousMessage",
        "previousSignature",
        "settlementMessage",
        "settlementPrice",
        "settlementSignature",
        "settlementTransactionHash",
        "settlementType"
    ]

    static let anyHedgeContractFeeFieldNames: Set<String> = [
        "address",
        "description",
        "name",
        "satoshis"
    ]
}
