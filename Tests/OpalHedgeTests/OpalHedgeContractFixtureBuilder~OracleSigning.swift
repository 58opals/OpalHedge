// OpalHedgeContractFixtureBuilder~OracleSigning.swift

import Foundation
import OpalHedge
import OpalCrypto

extension OpalHedgeContractFixtureBuilder {
    static func makeOracleMessageHex(
        messageTimestamp: Int64,
        messageSequence: Int64,
        priceSequence: Int64,
        priceValue: Int64
    ) -> String {
        [
            messageTimestamp,
            messageSequence,
            priceSequence,
            priceValue
        ]
        .flatMap(encodeLittleEndianInteger)
        .map(makeByteHex)
        .joined()
    }

    static func encodeLittleEndianInteger(_ value: Int64) -> [UInt8] {
        let integer = UInt32(bitPattern: Int32(value))

        return [
            UInt8(integer & 0xff),
            UInt8((integer >> 8) & 0xff),
            UInt8((integer >> 16) & 0xff),
            UInt8((integer >> 24) & 0xff)
        ]
    }

    static func makeByteHex(_ byte: UInt8) -> String {
        let text = String(byte, radix: 16)

        return text.count == 1 ? "0" + text : text
    }

    static let verifiedOraclePrivateKey = try! OpalCrypto.Secp256k1
        .PrivateKey(
            rawRepresentation: Data(
                [
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 1
                ]
            )
        )

    static func makeOracleSignatureHex(messageHex: String) throws -> String {
        let message = try OpalHedge.Oracle.PriceMessage.parse(rawHex: messageHex)
        let digest = try OpalCrypto.Signature.Digest(
            rawRepresentation: OpalCrypto.Hashing.sha256(message.rawMessageData)
        )
        let signature = try OpalCrypto.Signature.Schnorr.sign(
            digest: digest,
            privateKey: verifiedOraclePrivateKey
        )

        return hexText(signature.rawRepresentation)
    }

    static func hexText(_ data: Data) -> String {
        data.map(makeByteHex).joined()
    }
}
