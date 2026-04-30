// OpalHedgeOracleHexadecimalCodec.swift

import Foundation

enum OpalHedgeOracleHexadecimalCodec {
    static func decode(_ text: String) throws -> Data {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.count.isMultiple(of: 2) else {
            throw OpalHedgeOracleMessageError.invalidHexLength(actual: trimmedText.count)
        }

        var data = Data()
        data.reserveCapacity(trimmedText.count / 2)

        var index = trimmedText.startIndex
        while index < trimmedText.endIndex {
            let nextIndex = trimmedText.index(index, offsetBy: 2)
            let byteText = trimmedText[index..<nextIndex]
            guard let byte = UInt8(byteText, radix: 16) else {
                throw OpalHedgeOracleMessageError.invalidHexCharacter(String(byteText))
            }

            data.append(byte)
            index = nextIndex
        }

        return data
    }

    static func encode(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}
