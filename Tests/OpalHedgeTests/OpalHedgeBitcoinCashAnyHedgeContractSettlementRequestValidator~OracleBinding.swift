import Foundation
import OpalCrypto
import OpalHedge
import Testing

extension OpalHedgeBitcoinCashAnyHedgeContractSettlementRequestValidator {
    @Test(
        "Settlement request binds both verified proofs to its funded oracle",
        arguments: [(1, 1), (1, 2), (2, 1), (2, 2)]
    )
    func bindSettlementProofsToFundedOracle(
        previousSigner: UInt8,
        settlementSigner: UInt8
    ) throws {
        // The funded contract uses the fixture's private scalar 1. Every proof
        // below is independently signed and verified with its actual signer.
        let fundingRecord = try OpalHedge.Client.Context().createAnyHedgeContractFundingRecord(
            from: OpalHedgeContractFixtureBuilder.makeVerifiedCreationContext(),
            fundingTransactionHash: String(repeating: "1", count: 64),
            fundingOutputIndex: 0
        )
        let previousProof = try signedOracleProof(
            signer: previousSigner, timestamp: 615_643, sequence: 1, price: 23_600
        )
        let settlementProof = try signedOracleProof(
            signer: settlementSigner, timestamp: 6_663_643, sequence: 2, price: 23_500
        )

        if previousSigner == 1 && settlementSigner == 1 {
            let request = try fundingRecord.createSettlementRequest(
                previousOracleProof: previousProof,
                settlementOracleProof: settlementProof
            )
            #expect(request.settlementKind == .maturation)
            #expect(request.hedgePayoutInSatoshis == 4_255_319)
            #expect(request.longPayoutInSatoshis == 1_394_398)
        } else {
            #expect(throws: OpalHedgeSettlementOracleProofError.invalidSignature) {
                _ = try fundingRecord.createSettlementRequest(
                    previousOracleProof: previousProof,
                    settlementOracleProof: settlementProof
                )
            }
        }
    }

    private func signedOracleProof(
        signer: UInt8,
        timestamp: Int64,
        sequence: Int64,
        price: Int64
    ) throws -> OpalHedge.Core.ContractSettlementOracleProof {
        let key = try OpalCrypto.Secp256k1.PrivateKey(
            rawRepresentation: Data(Array(repeating: UInt8(0), count: 31) + [signer])
        )
        let messageHex = OpalHedgeContractFixtureBuilder.makeOracleMessageHex(
            messageTimestamp: timestamp,
            messageSequence: sequence,
            priceSequence: sequence,
            priceValue: price
        )
        let message = try OpalHedge.Oracle.PriceMessage.parse(rawHex: messageHex)
        let signature = try OpalCrypto.Signature.Schnorr.sign(
            digest: OpalCrypto.Signature.Digest(
                rawRepresentation: OpalCrypto.Hashing.sha256(message.rawMessageData)
            ),
            privateKey: key
        )
        return try OpalHedge.Oracle.verifySettlementOracleProof(
            messageHex: messageHex,
            signatureHex: OpalHedgeContractFixtureBuilder.hexText(signature.rawRepresentation),
            publicKeyHex: OpalHedgeContractFixtureBuilder.hexText(
                OpalCrypto.Secp256k1.derivePublicKey(from: key).compressedRepresentation
            )
        )
    }
}
