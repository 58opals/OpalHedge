// OpalHedgeFixtureData.swift

import OpalHedge

enum OpalHedgeFixtureData {
    static let oraclePublicKeyHex = "029174c105b4d7be73b0e25b3b204dfab054bd2c12f7d7e38a5de4f4d05decc58f"
    static let startingOracleMessageHex = "db6409000100000001000000305c0000"
    static let startingOracleSignatureHex =
        "a8744a655a03107fb3b8e46eaee5519899960f258726d4fa6a74b6cbeb9a62ef" +
        "e96e012233cfbefc44378b820eb76bc4ef11e196ae5d47116ed9cbad93c6a818"
    static let shortPayoutAddress = "bitcoincash:qq59hv6s3qdjrtyfwfxxldkuj9xsjmx48vrz882knz"
    static let longPayoutAddress = "bitcoincash:qpzlruwy4xu5rxjs3z37nsj29y7h59gwvsu4ddp0u4"
    static let shortLockScriptHex = "76a914285bb350881b21ac89724c6fb6dc914d096cd53b88ac"
    static let longLockScriptHex = "76a91445f1f1c4a9b9419a5088a3e9c24a293d7a150e6488ac"
    static let shortMutualRedeemPublicKeyHex =
        "020797d8fd4d2fa6fd7cdeabe2526bfea2b90525d6e8ad506ec4ee3c53885aa309"
    static let longMutualRedeemPublicKeyHex =
        "028a53f95eb631b460854fc836b2e5d31cad16364b4dc3d970babfbdcc3f2e4954"
    static let upstreamHedgeTenWeekContractDataDocumentJsonText =
        #"{"fees":[],"fundings":[],"metadata":{"durationInSeconds":6048000,"# +
        #""hedgeInputInOracleUnits":999.99996800000008,"# +
        #""hedgeInputInSatoshis":4237288,"# +
        #""hedgePayoutAddress":"bitcoincash:qq59hv6s3qdjrtyfwfxxldkuj9xsjmx48vrz882knz","# +
        #""highLiquidationPriceMultiplier":10,"# +
        #""longInputInOracleUnits":333.33324399999998,"# +
        #""longInputInSatoshis":1412429,"# +
        #""longPayoutAddress":"bitcoincash:qpzlruwy4xu5rxjs3z37nsj29y7h59gwvsu4ddp0u4","# +
        #""lowLiquidationPriceMultiplier":0.75,"# +
        #""makerSide":"Long","minerCostInSatoshis":632,"nominalUnits":1000,"# +
        #""startingOracleMessage":"db6409000100000001000000305c0000","# +
        #""startingOracleSignature":"# +
        #""a8744a655a03107fb3b8e46eaee5519899960f258726d4fa6a74b6cbeb9a62ef"# +
        #"e96e012233cfbefc44378b820eb76bc4ef11e196ae5d47116ed9cbad93c6a818","# +
        #""startPrice":23600,"takerSide":"Hedge"},"parameters":{"# +
        #""enableMutualRedemption":1,"# +
        #""hedgeLockScript":"76a914285bb350881b21ac89724c6fb6dc914d096cd53b88ac","# +
        #""hedgeMutualRedeemPublicKey":"# +
        #""020797d8fd4d2fa6fd7cdeabe2526bfea2b90525d6e8ad506ec4ee3c53885aa309","# +
        #""highLiquidationPrice":236000,"# +
        #""longLockScript":"76a91445f1f1c4a9b9419a5088a3e9c24a293d7a150e6488ac","# +
        #""longMutualRedeemPublicKey":"# +
        #""028a53f95eb631b460854fc836b2e5d31cad16364b4dc3d970babfbdcc3f2e4954","# +
        #""lowLiquidationPrice":17700,"maturityTimestamp":6663643,"# +
        #""nominalUnitsXSatsPerBch":100000000000,"# +
        #""oraclePublicKey":"029174c105b4d7be73b0e25b3b204dfab054bd2c12f7d7e38a5de4f4d05decc58f","# +
        #""payoutSats":5649717,"satsForNominalUnitsAtHighLiquidation":0,"# +
        #""startTimestamp":615643}}"#

    static let oracleContractPublicKey = try! OpalHedge.Core.ContractPublicKey(
        hex: oraclePublicKeyHex
    )
    static let shortMutualRedeemPublicKey = try! OpalHedge.Core.ContractPublicKey(
        hex: shortMutualRedeemPublicKeyHex
    )
    static let longMutualRedeemPublicKey = try! OpalHedge.Core.ContractPublicKey(
        hex: longMutualRedeemPublicKeyHex
    )
    static let contractOracleSignature = try! OpalHedge.Core.ContractOracleSignature(
        hex: startingOracleSignatureHex
    )
    static let contractOracleMessageData = try! OpalHedge.Core.ContractOracleMessageData(
        hex: startingOracleMessageHex
    )
    static let shortContractPayoutAddress = try! OpalHedge.Core.ContractPayoutAddress(
        shortPayoutAddress
    )
    static let longContractPayoutAddress = try! OpalHedge.Core.ContractPayoutAddress(
        longPayoutAddress
    )
    static let shortContractLockScript = try! OpalHedge.Core.ContractLockScript(
        hex: shortLockScriptHex
    )
    static let longContractLockScript = try! OpalHedge.Core.ContractLockScript(
        hex: longLockScriptHex
    )

    static let contractStartingOracleProof = OpalHedge.Core.ContractStartingOracleProof(
        oraclePublicKey: oracleContractPublicKey,
        message: contractOracleMessageData,
        signature: contractOracleSignature
    )

    static let contractParameters = OpalHedge.Core.ContractParameters(
        oraclePublicKey: oracleContractPublicKey,
        lowLiquidationPrice: 17_700,
        highLiquidationPrice: 236_000,
        startTimestamp: 615_643,
        maturityTimestamp: 6_663_643,
        nominalUnitsXSatsPerBch: 100_000_000_000,
        satsForNominalUnitsAtHighLiquidation: 0,
        payoutSats: 5_649_717,
        shortLockScript: shortContractLockScript,
        longLockScript: longContractLockScript,
        enableMutualRedemption: 1,
        shortMutualRedeemPublicKey: shortMutualRedeemPublicKey,
        longMutualRedeemPublicKey: longMutualRedeemPublicKey
    )

    static let contractCreationContext = OpalHedge.Core.ContractCreationContext(
        takerSide: .short,
        makerSide: .long,
        startingOracleProof: contractStartingOracleProof,
        shortPayoutAddress: shortContractPayoutAddress,
        longPayoutAddress: longContractPayoutAddress,
        shortLockScript: shortContractLockScript,
        longLockScript: longContractLockScript,
        nominalUnits: 1_000,
        maturityTimestamp: 6_663_643,
        isSimpleHedge: 1,
        highLiquidationPriceMultiplier: 10,
        lowLiquidationPriceMultiplier: 0.75,
        enableMutualRedemption: 1,
        shortMutualRedeemPublicKey: shortMutualRedeemPublicKey,
        longMutualRedeemPublicKey: longMutualRedeemPublicKey,
        minerCostInSatoshis: 632
    )
}
