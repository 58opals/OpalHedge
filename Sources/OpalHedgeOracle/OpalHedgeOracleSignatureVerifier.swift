// OpalHedgeOracleSignatureVerifier.swift

import Foundation
import OpalCrypto

public enum OpalHedgeOracleSignatureVerifier {
    public static func verify(
        message: OpalHedgeOraclePriceMessage,
        signatureHex: String,
        publicKeyHex: String
    ) throws -> Bool {
        try verify(
            message: message,
            signature: OpalHedgeOracleHexadecimalCodec.decode(signatureHex),
            publicKey: OpalHedgeOracleHexadecimalCodec.decode(publicKeyHex)
        )
    }

    public static func verify(
        message: OpalHedgeOraclePriceMessage,
        signature: Data,
        publicKey: Data
    ) throws -> Bool {
        let digest = OpalCrypto.Hashing.computeSHA256(message.rawData)

        do {
            return try OpalCrypto.Signature.verifySchnorr(
                signature: signature,
                digest: digest,
                publicKey: publicKey
            )
        } catch let error as OpalCrypto.Signature.Error {
            throw mapSignatureError(error)
        } catch {
            throw OpalHedgeOracleSignatureVerificationError.cryptographyFailure
        }
    }

    private static func mapSignatureError(
        _ error: OpalCrypto.Signature.Error
    ) -> OpalHedgeOracleSignatureVerificationError {
        switch error {
        case .invalidPublicKeyLength,
             .invalidPublicKeyPrefix,
             .invalidPublicKey:
            return .invalidPublicKey
        case .invalidSignatureLength:
            return .invalidSignature
        case .invalidDigestLength:
            return .invalidDigest
        case .invalidPrivateKeyLength,
             .invalidPrivateKey,
             .cryptographyFailure:
            return .cryptographyFailure
        }
    }
}
