// OpalHedgeOracleSignatureVerifier.swift

import Foundation
import OpalCrypto

public enum OpalHedgeOracleSignatureVerifier {
    public static func verify(
        message: OpalHedgeOraclePriceMessage,
        signatureHex: String,
        publicKeyHex: String
    ) throws -> Bool {
        let signature: Data
        let publicKey: Data
        signature = try decodeVerificationHex(
            signatureHex,
            payloadType: "signature_hex",
            message: message
        )
        publicKey = try decodeVerificationHex(
            publicKeyHex,
            payloadType: "public_key_hex",
            message: message
        )

        return try verify(
            message: message,
            signature: signature,
            publicKey: publicKey
        )
    }

    public static func verify(
        message: OpalHedgeOraclePriceMessage,
        signature: Data,
        publicKey: Data
    ) throws -> Bool {
        guard message.isCanonical else {
            OpalHedgeOracleDiagnostics.record(
                OpalHedgeOracleDiagnostics.Event.oracleSignatureVerificationFailed,
                level: .error,
                fields: [
                    OpalHedgeOracleDiagnostics.operationField("verify_oracle_signature"),
                    OpalHedgeOracleDiagnostics.moduleField("oracle"),
                    OpalHedgeOracleDiagnostics.publicField(
                        OpalHedgeOracleDiagnostics.Field.errorCode,
                        OpalHedgeOracleDiagnostics.ErrorCode.oracleInvalidSignature
                    ),
                    OpalHedgeOracleDiagnostics.publicField(
                        OpalHedgeOracleDiagnostics.Field.errorCategory,
                        "oracle_signature"
                    )
                ] + OpalHedgeOracleDiagnostics.makeMessageFields(for: message)
            )
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

            let isVerified = try schnorrSignature.verify(
                digest: digest,
                verificationKey: verificationKey
            )
            OpalHedgeOracleDiagnostics.record(
                isVerified
                    ? OpalHedgeOracleDiagnostics.Event.oracleSignatureVerified
                    : OpalHedgeOracleDiagnostics.Event.oracleSignatureVerificationFailed,
                level: isVerified ? .debug : .error,
                fields: [
                    OpalHedgeOracleDiagnostics.operationField("verify_oracle_signature"),
                    OpalHedgeOracleDiagnostics.moduleField("oracle")
                ] + (isVerified ? [] : [
                    OpalHedgeOracleDiagnostics.publicField(
                        OpalHedgeOracleDiagnostics.Field.errorCode,
                        OpalHedgeOracleDiagnostics.ErrorCode.oracleInvalidSignature
                    ),
                    OpalHedgeOracleDiagnostics.publicField(
                        OpalHedgeOracleDiagnostics.Field.errorCategory,
                        "oracle_signature"
                    )
                ]) + OpalHedgeOracleDiagnostics.makeMessageFields(for: message)
            )
            return isVerified
        } catch let error as OpalCrypto.Signature.Error {
            let mappedError = mapSignatureError(error)
            OpalHedgeOracleDiagnostics.record(
                OpalHedgeOracleDiagnostics.Event.oracleSignatureVerificationFailed,
                level: .error,
                fields: [
                    OpalHedgeOracleDiagnostics.operationField("verify_oracle_signature"),
                    OpalHedgeOracleDiagnostics.moduleField("oracle")
                ] + OpalHedgeOracleDiagnostics.makeMessageFields(for: message)
                    + OpalHedgeOracleDiagnostics.makeErrorFields(for: mappedError)
            )
            throw mappedError
        } catch {
            let mappedError = OpalHedgeOracleSignatureVerificationError.cryptographyFailure
            OpalHedgeOracleDiagnostics.record(
                OpalHedgeOracleDiagnostics.Event.oracleSignatureVerificationFailed,
                level: .error,
                fields: [
                    OpalHedgeOracleDiagnostics.operationField("verify_oracle_signature"),
                    OpalHedgeOracleDiagnostics.moduleField("oracle")
                ] + OpalHedgeOracleDiagnostics.makeMessageFields(for: message)
                    + OpalHedgeOracleDiagnostics.makeErrorFields(for: mappedError)
            )
            throw mappedError
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

    private static func decodeVerificationHex(
        _ text: String,
        payloadType: String,
        message: OpalHedgeOraclePriceMessage
    ) throws -> Data {
        do {
            return try OpalHedgeOracleHexadecimalCodec.decode(text)
        } catch {
            OpalHedgeOracleDiagnostics.record(
                OpalHedgeOracleDiagnostics.Event.oracleSignatureVerificationFailed,
                level: .error,
                fields: [
                    OpalHedgeOracleDiagnostics.operationField("verify_oracle_signature"),
                    OpalHedgeOracleDiagnostics.moduleField("oracle"),
                    OpalHedgeOracleDiagnostics.publicField(
                        OpalHedgeOracleDiagnostics.Field.payloadType,
                        payloadType
                    )
                ] + OpalHedgeOracleDiagnostics.makeMessageFields(for: message)
                    + OpalHedgeOracleDiagnostics.makeErrorFields(
                        for: error,
                        errorCategory: "oracle_signature"
                    )
            )
            throw error
        }
    }
}
