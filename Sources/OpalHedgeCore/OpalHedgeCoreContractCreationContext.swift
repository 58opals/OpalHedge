// OpalHedgeCoreContractCreationContext.swift

public struct OpalHedgeCoreContractCreationContext: Sendable, Equatable {
    public let takerSide: OpalHedgeCoreContractSide
    public let makerSide: OpalHedgeCoreContractSide
    public let startingOracleProof: OpalHedgeCoreContractStartingOracleProof
    public let shortPayoutAddress: OpalHedgeCoreContractPayoutAddress
    public let longPayoutAddress: OpalHedgeCoreContractPayoutAddress
    public let shortLockScript: OpalHedgeCoreContractLockScript
    public let longLockScript: OpalHedgeCoreContractLockScript
    public let nominalUnits: Double
    public let maturityTimestamp: Int64
    public let isSimpleHedge: Int64
    public let highLiquidationPriceMultiplier: Double
    public let lowLiquidationPriceMultiplier: Double
    public let enableMutualRedemption: Int64
    public let shortMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey
    public let longMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey
    public let minerCostInSatoshis: Int64

    public var shortMutualRedeemPublicKeyHex: String {
        shortMutualRedeemPublicKey.hex
    }

    public var longMutualRedeemPublicKeyHex: String {
        longMutualRedeemPublicKey.hex
    }

    public init(
        takerSide: OpalHedgeCoreContractSide,
        makerSide: OpalHedgeCoreContractSide,
        startingOracleProof: OpalHedgeCoreContractStartingOracleProof,
        shortPayoutAddress: OpalHedgeCoreContractPayoutAddress,
        longPayoutAddress: OpalHedgeCoreContractPayoutAddress,
        shortLockScript: OpalHedgeCoreContractLockScript,
        longLockScript: OpalHedgeCoreContractLockScript,
        nominalUnits: Double,
        maturityTimestamp: Int64,
        isSimpleHedge: Int64,
        highLiquidationPriceMultiplier: Double,
        lowLiquidationPriceMultiplier: Double,
        enableMutualRedemption: Int64,
        shortMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey,
        longMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey,
        minerCostInSatoshis: Int64 = 0
    ) {
        self.takerSide = takerSide
        self.makerSide = makerSide
        self.startingOracleProof = startingOracleProof
        self.shortPayoutAddress = shortPayoutAddress
        self.longPayoutAddress = longPayoutAddress
        self.shortLockScript = shortLockScript
        self.longLockScript = longLockScript
        self.nominalUnits = nominalUnits
        self.maturityTimestamp = maturityTimestamp
        self.isSimpleHedge = isSimpleHedge
        self.highLiquidationPriceMultiplier = highLiquidationPriceMultiplier
        self.lowLiquidationPriceMultiplier = lowLiquidationPriceMultiplier
        self.enableMutualRedemption = enableMutualRedemption
        self.shortMutualRedeemPublicKey = shortMutualRedeemPublicKey
        self.longMutualRedeemPublicKey = longMutualRedeemPublicKey
        self.minerCostInSatoshis = minerCostInSatoshis
    }

    public init(
        takerSide: OpalHedgeCoreContractSide,
        makerSide: OpalHedgeCoreContractSide,
        startingOracleProof: OpalHedgeCoreContractStartingOracleProof,
        shortPayoutAddress: String,
        longPayoutAddress: String,
        shortLockScriptHex: String,
        longLockScriptHex: String,
        nominalUnits: Double,
        maturityTimestamp: Int64,
        isSimpleHedge: Int64,
        highLiquidationPriceMultiplier: Double,
        lowLiquidationPriceMultiplier: Double,
        enableMutualRedemption: Int64,
        shortMutualRedeemPublicKeyHex: String,
        longMutualRedeemPublicKeyHex: String,
        minerCostInSatoshis: Int64 = 0
    ) throws {
        try self.init(
            takerSide: takerSide,
            makerSide: makerSide,
            startingOracleProof: startingOracleProof,
            shortPayoutAddress: OpalHedgeCoreContractPayoutAddress(shortPayoutAddress),
            longPayoutAddress: OpalHedgeCoreContractPayoutAddress(longPayoutAddress),
            shortLockScript: OpalHedgeCoreContractLockScript(hex: shortLockScriptHex),
            longLockScript: OpalHedgeCoreContractLockScript(hex: longLockScriptHex),
            nominalUnits: nominalUnits,
            maturityTimestamp: maturityTimestamp,
            isSimpleHedge: isSimpleHedge,
            highLiquidationPriceMultiplier: highLiquidationPriceMultiplier,
            lowLiquidationPriceMultiplier: lowLiquidationPriceMultiplier,
            enableMutualRedemption: enableMutualRedemption,
            shortMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey(
                hex: shortMutualRedeemPublicKeyHex,
                name: "shortMutualRedeemPublicKeyHex"
            ),
            longMutualRedeemPublicKey: OpalHedgeCoreContractPublicKey(
                hex: longMutualRedeemPublicKeyHex,
                name: "longMutualRedeemPublicKeyHex"
            ),
            minerCostInSatoshis: minerCostInSatoshis
        )
    }
}
