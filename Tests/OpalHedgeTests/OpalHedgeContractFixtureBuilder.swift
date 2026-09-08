// OpalHedgeContractFixtureBuilder.swift

import Foundation
import OpalHedge
import OpalCrypto

enum OpalHedgeContractFixtureBuilder {
    static let verifiedOraclePublicKeyHex = try! hexText(
        OpalCrypto.Secp256k1.derivePublicKey(
            from: verifiedOraclePrivateKey
        ).compressedRepresentation
    )

    static func makeVerifiedStartingOracleProof() throws
        -> OpalHedge.Core.ContractStartingOracleProof {
        let messageHex = makeOracleMessageHex(
            messageTimestamp: 615_643,
            messageSequence: 1,
            priceSequence: 1,
            priceValue: 23_600
        )

        return try OpalHedge.Oracle.verifyStartingPriceProof(
            messageHex: messageHex,
            signatureHex: makeOracleSignatureHex(messageHex: messageHex),
            publicKeyHex: verifiedOraclePublicKeyHex
        )
    }

    static func makeStartingSettlementOracleProof(
        signatureHex: String = OpalHedgeFixtureData.startingOracleSignatureHex
    ) throws -> OpalHedge.Core.ContractSettlementOracleProof {
        try OpalHedge.Core.ContractSettlementOracleProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: signatureHex
        )
    }

    static func makeVerifiedStartingSettlementOracleProof() throws
        -> OpalHedge.Core.ContractSettlementOracleProof {
        try makeVerifiedSettlementOracleProof(
            messageTimestamp: 615_643,
            messageSequence: 1,
            priceSequence: 1,
            priceValue: 23_600
        )
    }

    static func makeSettlementOracleProof(
        messageTimestamp: Int64 = 6_663_643,
        messageSequence: Int64 = 2,
        priceSequence: Int64 = 2,
        priceValue: Int64 = 23_500,
        signatureHex: String = OpalHedgeFixtureData.startingOracleSignatureHex
    ) throws -> OpalHedge.Core.ContractSettlementOracleProof {
        try OpalHedge.Core.ContractSettlementOracleProof(
            messageHex: makeOracleMessageHex(
                messageTimestamp: messageTimestamp,
                messageSequence: messageSequence,
                priceSequence: priceSequence,
                priceValue: priceValue
            ),
            signatureHex: signatureHex
        )
    }

    static func makeVerifiedSettlementOracleProof(
        messageTimestamp: Int64 = 6_663_643,
        messageSequence: Int64 = 2,
        priceSequence: Int64 = 2,
        priceValue: Int64 = 23_500
    ) throws -> OpalHedge.Core.ContractSettlementOracleProof {
        let messageHex = makeOracleMessageHex(
            messageTimestamp: messageTimestamp,
            messageSequence: messageSequence,
            priceSequence: priceSequence,
            priceValue: priceValue
        )

        return try OpalHedge.Oracle.verifySettlementOracleProof(
            messageHex: messageHex,
            signatureHex: makeOracleSignatureHex(messageHex: messageHex),
            publicKeyHex: verifiedOraclePublicKeyHex
        )
    }

    static func makeVerifiedCreationContext() throws
        -> OpalHedge.Core.ContractCreationContext {
        OpalHedge.Core.ContractCreationContext(
            takerSide: .short,
            makerSide: .long,
            startingOracleProof: try makeVerifiedStartingOracleProof(),
            shortPayoutAddress: try! OpalHedge.Core.ContractPayoutAddress(
                OpalHedgeFixtureData.shortPayoutAddress
            ),
            longPayoutAddress: try! OpalHedge.Core.ContractPayoutAddress(
                OpalHedgeFixtureData.longPayoutAddress
            ),
            shortLockScript: try! OpalHedge.Core.ContractLockScript(
                hex: OpalHedgeFixtureData.shortLockScriptHex
            ),
            longLockScript: try! OpalHedge.Core.ContractLockScript(
                hex: OpalHedgeFixtureData.longLockScriptHex
            ),
            nominalUnits: 1_000,
            maturityTimestamp: 6_663_643,
            isSimpleHedge: 1,
            highLiquidationPriceMultiplier: 10,
            lowLiquidationPriceMultiplier: 0.75,
            enableMutualRedemption: 1,
            shortMutualRedeemPublicKey: OpalHedgeFixtureData
                .shortMutualRedeemPublicKey,
            longMutualRedeemPublicKey: OpalHedgeFixtureData
                .longMutualRedeemPublicKey,
            minerCostInSatoshis: 632
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
