// OpalHedgeBitcoinCashHexadecimalCodec.swift

import Foundation

enum OpalHedgeBitcoinCashHexadecimalCodec {
    static func decode(_ hex: String) -> Data? {
        guard hex.count.isMultiple(of: 2) else {
            return nil
        }

        var data = Data()
        data.reserveCapacity(hex.count / 2)

        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            let byteText = hex[index..<nextIndex]
            guard byteText.utf8.allSatisfy({
                (0x30...0x39).contains($0)
                    || (0x41...0x46).contains($0)
                    || (0x61...0x66).contains($0)
            }), let byte = UInt8(byteText, radix: 16) else {
                return nil
            }

            data.append(byte)
            index = nextIndex
        }

        return data
    }
}
