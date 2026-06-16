// OpalHedgeBitcoinCashContractAddress.swift

import Foundation
import OpalCrypto
import OpalDiagnostics

public struct OpalHedgeBitcoinCashContractAddress: Sendable, Equatable {
    public let rawValue: String
    public let rawScriptHash: Data
    public let network: OpalHedgeBitcoinCashNetwork

    @available(*, deprecated, renamed: "rawScriptHash")
    public var scriptHash: Data {
        rawScriptHash
    }

    public init(
        rawScriptHash: Data,
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws {
        do {
            guard rawScriptHash.count == Self.scriptHashByteCount else {
                throw OpalHedgeBitcoinCashContractAddressError
                    .invalidScriptHashByteCount(rawScriptHash.count)
            }

            self.rawValue = try Self.cashAddr(
                rawScriptHash: rawScriptHash,
                network: network
            )
            self.rawScriptHash = rawScriptHash
            self.network = network
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractAddressEncoded,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("encode_contract_address"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.byteCount,
                        rawScriptHash.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        "script_hash"
                    )
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractAddressEncodingFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("encode_contract_address"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.byteCount,
                        rawScriptHash.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        "script_hash"
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    public init(
        rawRedeemScript: Data,
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws {
        try self.init(
            rawScriptHash: OpalCrypto.Hashing.hash160(rawRedeemScript),
            network: network
        )
    }

    public init(
        rawRedeemScriptHex: String,
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws {
        guard let redeemScript = OpalHedgeBitcoinCashHexadecimalCodec.decode(rawRedeemScriptHex) else {
            let error = OpalHedgeBitcoinCashContractAddressError.invalidRedeemScriptHex(
                rawRedeemScriptHex
            )
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractAddressEncodingFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("encode_contract_address"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        "redeem_script_hex"
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }

        try self.init(
            rawRedeemScript: redeemScript,
            network: network
        )
    }

    @available(*, deprecated, message: "Use init(rawScriptHash:network:) so raw script hash material is explicit.")
    public init(
        scriptHash: Data,
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws {
        try self.init(
            rawScriptHash: scriptHash,
            network: network
        )
    }

    @available(*, deprecated, message: "Use init(rawRedeemScript:network:) so raw redeem script material is explicit.")
    public init(
        redeemScript: Data,
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws {
        try self.init(
            rawRedeemScript: redeemScript,
            network: network
        )
    }

    @available(*, deprecated, message: "Use init(rawRedeemScriptHex:network:) so raw redeem script material is explicit.")
    public init(
        redeemScriptHex: String,
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws {
        try self.init(
            rawRedeemScriptHex: redeemScriptHex,
            network: network
        )
    }

    private static let payToScriptHashVersionByte: UInt8 = 0x08
    private static let scriptHashByteCount = 20
    private static let checksumByteCount = 8

    private static func cashAddr(
        rawScriptHash: Data,
        network: OpalHedgeBitcoinCashNetwork
    ) throws -> String {
        var payloadBytes = Data([payToScriptHashVersionByte])
        payloadBytes.append(rawScriptHash)

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
