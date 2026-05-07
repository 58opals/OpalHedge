// OpalHedgeBitcoinCashHexadecimalCodec.swift

import Foundation

enum OpalHedgeBitcoinCashHexadecimalCodec {
    static func decode(_ hex: String) -> Data? {
        guard hex.count.isMultiple(of: 2),
              hex.allSatisfy({ lowercaseHexCharacters.contains($0) }) else {
            return nil
        }

        let characters = Array(hex.utf8)
        var data = Data()
        data.reserveCapacity(characters.count / 2)

        for index in stride(from: 0, to: characters.count, by: 2) {
            let highNibble = decodeHexNibble(characters[index])
            let lowNibble = decodeHexNibble(characters[index + 1])
            data.append(highNibble << 4 | lowNibble)
        }

        return data
    }

    private static func decodeHexNibble(_ character: UInt8) -> UInt8 {
        if character >= UInt8(ascii: "0"), character <= UInt8(ascii: "9") {
            return character - UInt8(ascii: "0")
        }

        return character - UInt8(ascii: "a") + 10
    }

    private static var lowercaseHexCharacters: String {
        "0123456789abcdef"
    }
}
