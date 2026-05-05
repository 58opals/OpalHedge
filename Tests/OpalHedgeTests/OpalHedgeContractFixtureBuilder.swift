// OpalHedgeContractFixtureBuilder.swift

import OpalHedge

enum OpalHedgeContractFixtureBuilder {
    static func makeStartingOracleProof(
        oraclePublicKey: OpalHedge.Core.ContractPublicKey =
            OpalHedgeFixtureData.oracleContractPublicKey,
        message: OpalHedge.Core.ContractOracleMessageData =
            OpalHedgeFixtureData.contractOracleMessageData,
        signature: OpalHedge.Core.ContractOracleSignature =
            OpalHedgeFixtureData.contractOracleSignature
    ) -> OpalHedge.Core.ContractStartingOracleProof {
        OpalHedge.Core.ContractStartingOracleProof(
            oraclePublicKey: oraclePublicKey,
            message: message,
            signature: signature
        )
    }

    static func makeCreationContext(
        takerSide: OpalHedge.Core.ContractSide = .short,
        makerSide: OpalHedge.Core.ContractSide = .long,
        startingOracleProof: OpalHedge.Core.ContractStartingOracleProof =
            OpalHedgeFixtureData.contractStartingOracleProof,
        shortPayoutAddress: String = OpalHedgeFixtureData.shortPayoutAddress,
        longPayoutAddress: String = OpalHedgeFixtureData.longPayoutAddress,
        shortLockScriptHex: String = OpalHedgeFixtureData.shortLockScriptHex,
        longLockScriptHex: String = OpalHedgeFixtureData.longLockScriptHex,
        nominalUnits: Double = 1_000,
        maturityTimestamp: Int64 = 6_663_643,
        isSimpleHedge: Int64 = 1,
        highLiquidationPriceMultiplier: Double = 10,
        lowLiquidationPriceMultiplier: Double = 0.75,
        enableMutualRedemption: Int64 = 1,
        shortMutualRedeemPublicKey: OpalHedge.Core.ContractPublicKey =
            OpalHedgeFixtureData.shortMutualRedeemPublicKey,
        longMutualRedeemPublicKey: OpalHedge.Core.ContractPublicKey =
            OpalHedgeFixtureData.longMutualRedeemPublicKey,
        minerCostInSatoshis: Int64 = 632
    ) -> OpalHedge.Core.ContractCreationContext {
        OpalHedge.Core.ContractCreationContext(
            takerSide: takerSide,
            makerSide: makerSide,
            startingOracleProof: startingOracleProof,
            shortPayoutAddress: try! OpalHedge.Core.ContractPayoutAddress(shortPayoutAddress),
            longPayoutAddress: try! OpalHedge.Core.ContractPayoutAddress(longPayoutAddress),
            shortLockScript: try! OpalHedge.Core.ContractLockScript(hex: shortLockScriptHex),
            longLockScript: try! OpalHedge.Core.ContractLockScript(hex: longLockScriptHex),
            nominalUnits: nominalUnits,
            maturityTimestamp: maturityTimestamp,
            isSimpleHedge: isSimpleHedge,
            highLiquidationPriceMultiplier: highLiquidationPriceMultiplier,
            lowLiquidationPriceMultiplier: lowLiquidationPriceMultiplier,
            enableMutualRedemption: enableMutualRedemption,
            shortMutualRedeemPublicKey: shortMutualRedeemPublicKey,
            longMutualRedeemPublicKey: longMutualRedeemPublicKey,
            minerCostInSatoshis: minerCostInSatoshis
        )
    }

    static func makeParameters(
        oraclePublicKey: OpalHedge.Core.ContractPublicKey =
            OpalHedgeFixtureData.oracleContractPublicKey,
        lowLiquidationPrice: Int64 = 17_700,
        highLiquidationPrice: Int64 = 236_000,
        startTimestamp: Int64 = 615_643,
        maturityTimestamp: Int64 = 6_663_643,
        nominalUnitsXSatsPerBch: Int64 = 100_000_000_000,
        satsForNominalUnitsAtHighLiquidation: Int64 = 0,
        payoutSats: Int64 = 5_649_717,
        shortLockScriptHex: String = OpalHedgeFixtureData.shortLockScriptHex,
        longLockScriptHex: String = OpalHedgeFixtureData.longLockScriptHex,
        enableMutualRedemption: Int64 = 1,
        shortMutualRedeemPublicKey: OpalHedge.Core.ContractPublicKey =
            OpalHedgeFixtureData.shortMutualRedeemPublicKey,
        longMutualRedeemPublicKey: OpalHedge.Core.ContractPublicKey =
            OpalHedgeFixtureData.longMutualRedeemPublicKey
    ) -> OpalHedge.Core.ContractParameters {
        OpalHedge.Core.ContractParameters(
            oraclePublicKey: oraclePublicKey,
            lowLiquidationPrice: lowLiquidationPrice,
            highLiquidationPrice: highLiquidationPrice,
            startTimestamp: startTimestamp,
            maturityTimestamp: maturityTimestamp,
            nominalUnitsXSatsPerBch: nominalUnitsXSatsPerBch,
            satsForNominalUnitsAtHighLiquidation: satsForNominalUnitsAtHighLiquidation,
            payoutSats: payoutSats,
            shortLockScript: try! OpalHedge.Core.ContractLockScript(hex: shortLockScriptHex),
            longLockScript: try! OpalHedge.Core.ContractLockScript(hex: longLockScriptHex),
            enableMutualRedemption: enableMutualRedemption,
            shortMutualRedeemPublicKey: shortMutualRedeemPublicKey,
            longMutualRedeemPublicKey: longMutualRedeemPublicKey
        )
    }
}
