// OpalHedgeBitcoinCashContractAddress.swift

import Foundation
import OpalCrypto

public struct OpalHedgeBitcoinCashContractAddress: Sendable, Equatable {
    public let rawValue: String
    public let scriptHash: Data
    public let network: OpalHedgeBitcoinCashNetwork

    public init(
        scriptHash: Data,
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws {
        do {
            guard scriptHash.count == Self.scriptHashByteCount else {
                throw OpalHedgeBitcoinCashContractAddressError
                    .invalidScriptHashByteCount(scriptHash.count)
            }

            self.rawValue = try Self.cashAddr(
                scriptHash: scriptHash,
                network: network
            )
            self.scriptHash = scriptHash
            self.network = network
            OpalHedgeBitcoinCashDiagnostics.record(
                OpalHedgeBitcoinCashDiagnostics.Event.contractAddressEncoded,
                fields: [
                    OpalHedgeBitcoinCashDiagnostics.operationField("encode_contract_address"),
                    OpalHedgeBitcoinCashDiagnostics.moduleField("bitcoin_cash"),
                    OpalHedgeBitcoinCashDiagnostics.networkField(network),
                    OpalHedgeBitcoinCashDiagnostics.publicField(
                        OpalHedgeBitcoinCashDiagnostics.Field.byteCount,
                        scriptHash.count
                    ),
                    OpalHedgeBitcoinCashDiagnostics.publicField(
                        OpalHedgeBitcoinCashDiagnostics.Field.payloadType,
                        "script_hash"
                    )
                ]
            )
        } catch {
            OpalHedgeBitcoinCashDiagnostics.record(
                OpalHedgeBitcoinCashDiagnostics.Event.contractAddressEncodingFailed,
                level: .error,
                fields: [
                    OpalHedgeBitcoinCashDiagnostics.operationField("encode_contract_address"),
                    OpalHedgeBitcoinCashDiagnostics.moduleField("bitcoin_cash"),
                    OpalHedgeBitcoinCashDiagnostics.networkField(network),
                    OpalHedgeBitcoinCashDiagnostics.publicField(
                        OpalHedgeBitcoinCashDiagnostics.Field.byteCount,
                        scriptHash.count
                    ),
                    OpalHedgeBitcoinCashDiagnostics.publicField(
                        OpalHedgeBitcoinCashDiagnostics.Field.payloadType,
                        "script_hash"
                    )
                ] + OpalHedgeBitcoinCashDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }
    }

    public init(
        redeemScript: Data,
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws {
        try self.init(
            scriptHash: OpalCrypto.Hashing.hash160(redeemScript),
            network: network
        )
    }

    public init(
        redeemScriptHex: String,
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws {
        guard let redeemScript = OpalHedgeBitcoinCashHexadecimalCodec.decode(redeemScriptHex) else {
            let error = OpalHedgeBitcoinCashContractAddressError.invalidRedeemScriptHex(
                redeemScriptHex
            )
            OpalHedgeBitcoinCashDiagnostics.record(
                OpalHedgeBitcoinCashDiagnostics.Event.contractAddressEncodingFailed,
                level: .error,
                fields: [
                    OpalHedgeBitcoinCashDiagnostics.operationField("encode_contract_address"),
                    OpalHedgeBitcoinCashDiagnostics.moduleField("bitcoin_cash"),
                    OpalHedgeBitcoinCashDiagnostics.networkField(network),
                    OpalHedgeBitcoinCashDiagnostics.publicField(
                        OpalHedgeBitcoinCashDiagnostics.Field.payloadType,
                        "redeem_script_hex"
                    )
                ] + OpalHedgeBitcoinCashDiagnostics.makeErrorFields(for: error)
            )
            throw error
        }

        try self.init(
            redeemScript: redeemScript,
            network: network
        )
    }

    private static let payToScriptHashVersionByte: UInt8 = 0x08
    private static let scriptHashByteCount = 20
    private static let checksumByteCount = 8

    private static func cashAddr(
        scriptHash: Data,
        network: OpalHedgeBitcoinCashNetwork
    ) throws -> String {
        var payloadBytes = Data([payToScriptHashVersionByte])
        payloadBytes.append(scriptHash)

        let payloadValues = fiveBitValues(from: payloadBytes)
        let checksumValues = try checksumValues(
            prefix: network.cashAddrPrefix,
            payload: payloadValues
        )

        var encodedPayloadValues = Data(payloadValues)
        encodedPayloadValues.append(contentsOf: checksumValues)

        let encodedPayload = try OpalCrypto.Encoding.encodeBase32Values(
            OpalCrypto.Encoding.FiveBitValues(
                rawRepresentation: encodedPayloadValues
            )
        )

        return "\(network.cashAddrPrefix):\(encodedPayload)"
    }

    private static func fiveBitValues(from bytes: Data) -> [UInt8] {
        var values: [UInt8] = []
        var accumulator = 0
        var bitCount = 0

        values.reserveCapacity((bytes.count * 8 + 4) / 5)

        for byte in bytes {
            accumulator = (accumulator << 8) | Int(byte)
            bitCount += 8

            while bitCount >= 5 {
                bitCount -= 5
                values.append(UInt8((accumulator >> bitCount) & 0x1f))
            }

            accumulator &= (1 << bitCount) - 1
        }

        if bitCount > 0 {
            values.append(UInt8((accumulator << (5 - bitCount)) & 0x1f))
        }

        return values
    }

    private static func checksumValues(prefix: String, payload: [UInt8]) throws -> [UInt8] {
        var values = prefix.utf8.map { $0 & 0x1f }
        values.append(0)
        values.append(contentsOf: payload)
        values.append(contentsOf: Array(repeating: 0, count: checksumByteCount))

        let checksum = try OpalCrypto.Encoding.computePolymodChecksum(
            OpalCrypto.Encoding.FiveBitValues(
                rawRepresentation: Data(values)
            )
        )

        return (0..<checksumByteCount).map { index in
            UInt8((checksum >> (5 * (checksumByteCount - 1 - index))) & 0x1f)
        }
    }

}
