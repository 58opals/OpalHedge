// OpalHedgeCoreContractCryptographyConstraintValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractCryptographyConstraintValidator {
    @Test("Derives oracle proof message fields from hex")
    func deriveOracleProofMessageFieldsFromHex() throws {
        let message = try OpalHedge.Core.ContractOracleMessageData(
            hex: OpalHedgeFixtureData.startingOracleMessageHex
        )

        #expect(message.messageTimestamp == 615_643)
        #expect(message.messageSequence == 1)
        #expect(message.priceSequence == 1)
        #expect(message.priceValue == 23_600)
    }

    @Test("Rejects invalid oracle proof public key")
    func rejectInvalidOracleProofPublicKey() {
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractPublicKey(hex: invalidPublicKeyHex)
        }

        #expect(
            error == .invalidPublicKeyHex(
                name: "hex",
                value: invalidPublicKeyHex
            )
        )
    }

    @Test("Rejects invalid oracle proof message hex")
    func rejectInvalidOracleProofMessageHex() {
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractOracleMessageData(
                hex: "00",
                messageTimestamp: 615_643,
                messageSequence: 1,
                priceSequence: 1,
                priceValue: 23_600
            )
        }

        #expect(error == .invalidOracleMessageHex(name: "hex", value: "00"))
    }

    @Test("Rejects inconsistent oracle proof message component")
    func rejectInconsistentOracleProofMessageComponent() {
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractOracleMessageData(
                hex: OpalHedgeFixtureData.startingOracleMessageHex,
                messageTimestamp: 615_644,
                messageSequence: 1,
                priceSequence: 1,
                priceValue: 23_600
            )
        }

        #expect(
            error == .inconsistentOracleMessageComponent(
                name: "messageTimestamp",
                expected: 615_643,
                actual: 615_644
            )
        )
    }

    @Test("Rejects invalid oracle proof signature hex")
    func rejectInvalidOracleProofSignatureHex() {
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractOracleSignature(hex: "00")
        }

        #expect(error == .invalidOracleSignatureHex(name: "hex", value: "00"))
    }

    @Test("Rejects invalid mutual redemption public key")
    func rejectInvalidMutualRedemptionPublicKey() {
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractCreationContext(
                takerSide: .short,
                makerSide: .long,
                startingOracleProof: OpalHedgeFixtureData.contractStartingOracleProof,
                shortPayoutAddress: OpalHedgeFixtureData.shortPayoutAddress,
                longPayoutAddress: OpalHedgeFixtureData.longPayoutAddress,
                shortLockScriptHex: OpalHedgeFixtureData.shortLockScriptHex,
                longLockScriptHex: OpalHedgeFixtureData.longLockScriptHex,
                nominalUnits: 1_000,
                maturityTimestamp: 6_663_643,
                isSimpleHedge: 1,
                highLiquidationPriceMultiplier: 10,
                lowLiquidationPriceMultiplier: 0.75,
                enableMutualRedemption: 1,
                shortMutualRedeemPublicKeyHex: invalidPublicKeyHex,
                longMutualRedeemPublicKeyHex: OpalHedgeFixtureData.longMutualRedeemPublicKeyHex
            )
        }

        #expect(
            error == .invalidPublicKeyHex(
                name: "shortMutualRedeemPublicKeyHex",
                value: invalidPublicKeyHex
            )
        )
    }

    @Test("Rejects invalid parameter oracle public key")
    func rejectInvalidParameterOraclePublicKey() {
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            _ = try OpalHedge.Core.ContractParameters(
                oraclePublicKeyHex: invalidPublicKeyHex,
                lowLiquidationPrice: 17_700,
                highLiquidationPrice: 236_000,
                startTimestamp: 615_643,
                maturityTimestamp: 6_663_643,
                nominalUnitsXSatsPerBch: 100_000_000_000,
                satsForNominalUnitsAtHighLiquidation: 0,
                payoutSats: 5_649_717,
                shortLockScriptHex: OpalHedgeFixtureData.shortLockScriptHex,
                longLockScriptHex: OpalHedgeFixtureData.longLockScriptHex,
                enableMutualRedemption: 1,
                shortMutualRedeemPublicKeyHex: OpalHedgeFixtureData.shortMutualRedeemPublicKeyHex,
                longMutualRedeemPublicKeyHex: OpalHedgeFixtureData.longMutualRedeemPublicKeyHex
            )
        }

        #expect(
            error == .invalidPublicKeyHex(
                name: "oraclePublicKeyHex",
                value: invalidPublicKeyHex
            )
        )
    }

    private var invalidPublicKeyHex: String {
        "04" + String(repeating: "0", count: 64)
    }
}
