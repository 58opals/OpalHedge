// OpalHedgeCoreContractParameters.swift

public struct OpalHedgeCoreContractParameters: Sendable, Equatable {
    public let oraclePublicKeyHex: String
    public let lowLiquidationPrice: Int64
    public let highLiquidationPrice: Int64
    public let startTimestamp: Int64
    public let maturityTimestamp: Int64
    public let nominalUnitsXSatsPerBch: Int64
    public let satsForNominalUnitsAtHighLiquidation: Int64
    public let payoutSats: Int64
    public let shortLockScriptHex: String
    public let longLockScriptHex: String
    public let enableMutualRedemption: Int64
    public let shortMutualRedeemPublicKeyHex: String
    public let longMutualRedeemPublicKeyHex: String

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
    ) {
        self.oraclePublicKeyHex = oraclePublicKeyHex
        self.lowLiquidationPrice = lowLiquidationPrice
        self.highLiquidationPrice = highLiquidationPrice
        self.startTimestamp = startTimestamp
        self.maturityTimestamp = maturityTimestamp
        self.nominalUnitsXSatsPerBch = nominalUnitsXSatsPerBch
        self.satsForNominalUnitsAtHighLiquidation = satsForNominalUnitsAtHighLiquidation
        self.payoutSats = payoutSats
        self.shortLockScriptHex = shortLockScriptHex
        self.longLockScriptHex = longLockScriptHex
        self.enableMutualRedemption = enableMutualRedemption
        self.shortMutualRedeemPublicKeyHex = shortMutualRedeemPublicKeyHex
        self.longMutualRedeemPublicKeyHex = longMutualRedeemPublicKeyHex
    }
}
