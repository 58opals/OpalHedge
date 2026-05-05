// OpalHedgeCoreContractParameters.swift

public struct OpalHedgeCoreContractParameters: Sendable, Equatable {
    public let oraclePublicKey: OpalHedgeCoreContractPublicKey
    public let lowLiquidationPrice: Int64
    public let highLiquidationPrice: Int64
    public let startTimestamp: Int64
    public let maturityTimestamp: Int64
    public let nominalUnitsXSatsPerBch: Int64
    public let satsForNominalUnitsAtHighLiquidation: Int64
    public let payoutSats: Int64
    public let shortLockScript: OpalHedgeCoreContractLockScript
    public let longLockScript: OpalHedgeCoreContractLockScript
    public let enableMutualRedemption: Int64
    public let shortMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey
    public let longMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey

    public var oraclePublicKeyHex: String {
        oraclePublicKey.hex
    }

    public var shortLockScriptHex: String {
        shortLockScript.hex
    }

    public var longLockScriptHex: String {
        longLockScript.hex
    }

    public var shortMutualRedeemPublicKeyHex: String {
        shortMutualRedeemPublicKey.hex
    }

    public var longMutualRedeemPublicKeyHex: String {
        longMutualRedeemPublicKey.hex
    }

    public init(
        oraclePublicKey: OpalHedgeCoreContractPublicKey,
        lowLiquidationPrice: Int64,
        highLiquidationPrice: Int64,
        startTimestamp: Int64,
        maturityTimestamp: Int64,
        nominalUnitsXSatsPerBch: Int64,
        satsForNominalUnitsAtHighLiquidation: Int64,
        payoutSats: Int64,
        shortLockScript: OpalHedgeCoreContractLockScript,
        longLockScript: OpalHedgeCoreContractLockScript,
        enableMutualRedemption: Int64,
        shortMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey,
        longMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey
    ) {
        self.oraclePublicKey = oraclePublicKey
        self.lowLiquidationPrice = lowLiquidationPrice
        self.highLiquidationPrice = highLiquidationPrice
        self.startTimestamp = startTimestamp
        self.maturityTimestamp = maturityTimestamp
        self.nominalUnitsXSatsPerBch = nominalUnitsXSatsPerBch
        self.satsForNominalUnitsAtHighLiquidation = satsForNominalUnitsAtHighLiquidation
        self.payoutSats = payoutSats
        self.shortLockScript = shortLockScript
        self.longLockScript = longLockScript
        self.enableMutualRedemption = enableMutualRedemption
        self.shortMutualRedeemPublicKey = shortMutualRedeemPublicKey
        self.longMutualRedeemPublicKey = longMutualRedeemPublicKey
    }

    package init(from context: OpalHedgeCoreContractParametersContext) throws {
        try self.init(
            from: OpalHedgeCoreContractPlanDerivationContext(
                creationContext: context.creationContext,
                fundingAmounts: context.fundingAmounts
            )
        )
    }

    public init(from context: OpalHedgeCoreContractPlanDerivationContext) throws {
        let creationContext = context.creationContext
        let fundingAmounts = context.fundingAmounts
        let startingOracleProof = creationContext.startingOracleProof
        self.init(
            oraclePublicKey: startingOracleProof.oraclePublicKey,
            lowLiquidationPrice: fundingAmounts.lowLiquidationPrice,
            highLiquidationPrice: fundingAmounts.highLiquidationPrice,
            startTimestamp: startingOracleProof.messageTimestamp,
            maturityTimestamp: creationContext.maturityTimestamp,
            nominalUnitsXSatsPerBch: fundingAmounts.nominalUnitsXSatsPerBitcoinCash,
            satsForNominalUnitsAtHighLiquidation: fundingAmounts.satsForNominalUnitsAtHighLiquidation,
            payoutSats: fundingAmounts.payoutSats,
            shortLockScript: creationContext.shortLockScript,
            longLockScript: creationContext.longLockScript,
            enableMutualRedemption: creationContext.enableMutualRedemption,
            shortMutualRedeemPublicKey: creationContext.shortMutualRedeemPublicKey,
            longMutualRedeemPublicKey: creationContext.longMutualRedeemPublicKey
        )

        try OpalHedgeCoreContractConstraintEvaluator.validateParameters(
            self,
            startPrice: startingOracleProof.priceValue
        )
    }

    public init(
        oraclePublicKeyHex: String,
        lowLiquidationPrice: Int64,
        highLiquidationPrice: Int64,
        startTimestamp: Int64,
        maturityTimestamp: Int64,
        nominalUnitsXSatsPerBch: Int64,
        satsForNominalUnitsAtHighLiquidation: Int64,
        payoutSats: Int64,
        shortLockScriptHex: String,
        longLockScriptHex: String,
        enableMutualRedemption: Int64,
        shortMutualRedeemPublicKeyHex: String,
        longMutualRedeemPublicKeyHex: String
    ) throws {
        try self.init(
            oraclePublicKey: OpalHedgeCoreContractPublicKey(
                hex: oraclePublicKeyHex,
                name: "oraclePublicKeyHex"
            ),
            lowLiquidationPrice: lowLiquidationPrice,
            highLiquidationPrice: highLiquidationPrice,
            startTimestamp: startTimestamp,
            maturityTimestamp: maturityTimestamp,
            nominalUnitsXSatsPerBch: nominalUnitsXSatsPerBch,
            satsForNominalUnitsAtHighLiquidation: satsForNominalUnitsAtHighLiquidation,
            payoutSats: payoutSats,
            shortLockScript: OpalHedgeCoreContractLockScript(hex: shortLockScriptHex),
            longLockScript: OpalHedgeCoreContractLockScript(hex: longLockScriptHex),
            enableMutualRedemption: enableMutualRedemption,
            shortMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey(
                hex: shortMutualRedeemPublicKeyHex,
                name: "shortMutualRedeemPublicKeyHex"
            ),
            longMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey(
                hex: longMutualRedeemPublicKeyHex,
                name: "longMutualRedeemPublicKeyHex"
            )
        )
    }
}
