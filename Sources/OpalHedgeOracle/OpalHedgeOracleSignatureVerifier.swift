// OpalHedgeOracleSignatureVerifier.swift

import Foundation
import OpalCrypto
import OpalDiagnostics

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
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                event: OpalDiagnostics.Event.oracleSignatureVerificationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("verify_oracle_signature"),
                    OpalDiagnostics.Field.moduleField("oracle")
                ] + OpalDiagnostics.Field.makeErrorFields(
                    for: OpalHedgeOracleSignatureVerificationError.invalidSignature,
                    errorCategory: "oracle_signature"
                ) + OpalDiagnostics.Field.makeMessageFields(for: message)
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
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                event: isVerified
                    ? OpalDiagnostics.Event.oracleSignatureVerified
                    : OpalDiagnostics.Event.oracleSignatureVerificationFailed,
                level: isVerified ? .debug : .error,
                fields: [
                    OpalDiagnostics.Field.operationField("verify_oracle_signature"),
                    OpalDiagnostics.Field.moduleField("oracle")
                ] + (isVerified ? [] : OpalDiagnostics.Field.makeErrorFields(
                    for: OpalHedgeOracleSignatureVerificationError.invalidSignature,
                    errorCategory: "oracle_signature"
                )) + OpalDiagnostics.Field.makeMessageFields(for: message)
            )
            return isVerified
        } catch let error as OpalCrypto.Signature.Error {
            let mappedError = mapSignatureError(error)
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                event: OpalDiagnostics.Event.oracleSignatureVerificationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("verify_oracle_signature"),
                    OpalDiagnostics.Field.moduleField("oracle")
                ] + OpalDiagnostics.Field.makeMessageFields(for: message)
                    + OpalDiagnostics.Field.makeErrorFields(for: mappedError)
            )
            throw mappedError
        } catch {
            let mappedError = OpalHedgeOracleSignatureVerificationError.cryptographyFailure
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                event: OpalDiagnostics.Event.oracleSignatureVerificationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("verify_oracle_signature"),
                    OpalDiagnostics.Field.moduleField("oracle")
                ] + OpalDiagnostics.Field.makeMessageFields(for: message)
                    + OpalDiagnostics.Field.makeErrorFields(for: mappedError)
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
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                event: OpalDiagnostics.Event.oracleSignatureVerificationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("verify_oracle_signature"),
                    OpalDiagnostics.Field.moduleField("oracle"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        payloadType
                    )
                ] + OpalDiagnostics.Field.makeMessageFields(for: message)
                    + OpalDiagnostics.Field.makeErrorFields(
                        for: error,
                        errorCategory: "oracle_signature"
                    )
            )
            throw error
        }
    }
}
