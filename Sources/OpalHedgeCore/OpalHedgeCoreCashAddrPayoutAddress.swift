// OpalHedgeCoreCashAddrPayoutAddress.swift

struct OpalHedgeCoreCashAddrPayoutAddress: Sendable, Equatable {
    let cashAddrPrefix: String
    let publicKeyHashHex: String

    static func parse(
        _ value: String,
        name: String
    ) throws -> OpalHedgeCoreCashAddrPayoutAddress {
        let isLowercase = value == value.lowercased()
        let isUppercase = value == value.uppercased()
        guard isLowercase || isUppercase else {
            throw OpalHedgeCoreContractConstraintError.invalidPayoutAddress(
                name: name,
                value: value
            )
        }

        let normalizedValue = value.lowercased()
        let parts = normalizedValue.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 2 else {
            throw OpalHedgeCoreContractConstraintError.invalidPayoutAddress(
                name: name,
                value: value
            )
        }

        let prefix = String(parts[0])
        let payloadText = parts[1]
        guard supportedPrefixes.contains(prefix),
              payloadText.count == encodedPayloadCharacterCount else {
            throw OpalHedgeCoreContractConstraintError.invalidPayoutAddress(
                name: name,
                value: value
            )
        }

        let payloadValues = try fiveBitValues(
            from: payloadText.utf8,
            name: name,
            value: value
        )
        let checksumInput = prefixValues(prefix) + payloadValues
        guard polymod(checksumInput) == validChecksum else {
            throw OpalHedgeCoreContractConstraintError.invalidPayoutAddress(
                name: name,
                value: value
            )
        }

        let payloadWithoutChecksum = payloadValues.dropLast(checksumValueCount)
        let payloadBytes = try bytes(
            from: payloadWithoutChecksum,
            name: name,
            value: value
        )
        guard payloadBytes.count == expectedPayloadByteCount,
              payloadBytes.first == payToPublicKeyHashVersionByte else {
            throw OpalHedgeCoreContractConstraintError.invalidPayoutAddress(
                name: name,
                value: value
            )
        }

        return Self(
            cashAddrPrefix: prefix,
            publicKeyHashHex: hexString(payloadBytes.dropFirst())
        )
    }

    private static let supportedPrefixes = [
        "bitcoincash",
        "bchtest",
        "bchreg"
    ]
    private static let encodedPayloadCharacterCount = 42
    private static let checksumValueCount = 8
    private static let expectedPayloadByteCount = 21
    private static let payToPublicKeyHashVersionByte: UInt8 = 0
    private static let validChecksum: UInt64 = 1
    private static let cashAddrCharacters = Array(
        "qpzry9x8gf2tvdw0s3jn54khce6mua7l".utf8
    )
    private static let checksumGenerators: [UInt64] = [
        0x98f2bc8e61,
        0x79b76d99e2,
        0xf33e5fb3c4,
        0xae2eabe2a8,
        0x1e4f43e470
    ]
    private static let hexDigits = Array("0123456789abcdef".utf8)

    private static func fiveBitValues(
        from characters: Substring.UTF8View,
        name: String,
        value: String
    ) throws -> [UInt8] {
        try characters.map { character in
            guard let index = cashAddrCharacters.firstIndex(of: character) else {
                throw OpalHedgeCoreContractConstraintError.invalidPayoutAddress(
                    name: name,
                    value: value
                )
            }

            return UInt8(index)
        }
    }

    private static func bytes(
        from values: ArraySlice<UInt8>,
        name: String,
        value: String
    ) throws -> [UInt8] {
        var bytes: [UInt8] = []
        var accumulator = 0
        var bitCount = 0

        for fiveBitValue in values {
            accumulator = (accumulator << 5) | Int(fiveBitValue)
            bitCount += 5

            while bitCount >= 8 {
                bitCount -= 8
                bytes.append(UInt8((accumulator >> bitCount) & 0xff))
                accumulator &= (1 << bitCount) - 1
            }
        }

        guard bitCount < 5, accumulator == 0 else {
            throw OpalHedgeCoreContractConstraintError.invalidPayoutAddress(
                name: name,
                value: value
            )
        }

        return bytes
    }

    private static func prefixValues(_ prefix: String) -> [UInt8] {
        prefix.utf8.map { $0 & 0x1f } + [0]
    }

    private static func polymod(_ values: [UInt8]) -> UInt64 {
        var checksum: UInt64 = 1

        for value in values {
            let top = checksum >> 35
            checksum = ((checksum & 0x07ffffffff) << 5) ^ UInt64(value)
            for index in checksumGenerators.indices {
                guard ((top >> UInt64(index)) & 1) == 1 else {
                    continue
                }

                checksum ^= checksumGenerators[index]
            }
        }

        return checksum
    }

    private static func hexString(_ bytes: ArraySlice<UInt8>) -> String {
        var encodedBytes: [UInt8] = []
        encodedBytes.reserveCapacity(bytes.count * 2)

        for byte in bytes {
            encodedBytes.append(hexDigits[Int(byte >> 4)])
            encodedBytes.append(hexDigits[Int(byte & 0x0f)])
        }

        return String(decoding: encodedBytes, as: UTF8.self)
    }
}
