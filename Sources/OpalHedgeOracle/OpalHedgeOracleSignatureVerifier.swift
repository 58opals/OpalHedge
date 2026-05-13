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
        guard message.isCanonical else {
            return false
        }

        do {
            let digest = try OpalCrypto.Signature.Digest(
                rawRepresentation: OpalCrypto.Hashing.sha256(message.rawData)
            )
            let schnorrSignature = try OpalCrypto.Signature.Schnorr(
                rawRepresentation: signature
            )
            let verificationKey = try OpalCrypto.Signature.VerificationKey(
                rawRepresentation: publicKey
            )

            return try schnorrSignature.verify(
                digest: digest,
                verificationKey: verificationKey
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
        case .invalidSignatureLength,
             .invalidSignature,
             .invalidDER,
             .nonCanonicalDER:
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
