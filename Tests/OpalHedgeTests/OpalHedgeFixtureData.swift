// OpalHedgeFixtureData.swift

import OpalHedge

enum OpalHedgeFixtureData {
    static let oraclePublicKeyHex = "029174c105b4d7be73b0e25b3b204dfab054bd2c12f7d7e38a5de4f4d05decc58f"
    static let startingOracleMessageHex = "db6409000100000001000000305c0000"
    static let startingOracleSignatureHex =
        "a8744a655a03107fb3b8e46eaee5519899960f258726d4fa6a74b6cbeb9a62ef" +
        "e96e012233cfbefc44378b820eb76bc4ef11e196ae5d47116ed9cbad93c6a818"

    static let contractParameters = OpalHedge.Core.ContractParameters(
        oraclePublicKeyHex: oraclePublicKeyHex,
        lowLiquidationPrice: 17_700,
        highLiquidationPrice: 236_000,
        startTimestamp: 615_643,
        maturityTimestamp: 6_663_643,
        nominalUnitsXSatsPerBch: 100_000_000_000,
        satsForNominalUnitsAtHighLiquidation: 0,
        payoutSats: 5_649_717,
        shortLockScriptHex: "76a914285bb350881b21ac89724c6fb6dc914d096cd53b88ac",
        longLockScriptHex: "76a91445f1f1c4a9b9419a5088a3e9c24a293d7a150e6488ac",
        enableMutualRedemption: 1,
        shortMutualRedeemPublicKeyHex: "020797d8fd4d2fa6fd7cdeabe2526bfea2b90525d6e8ad506ec4ee3c53885aa309",
        longMutualRedeemPublicKeyHex: "028a53f95eb631b460854fc836b2e5d31cad16364b4dc3d970babfbdcc3f2e4954"
    )
}
