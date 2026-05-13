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
            guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else {
                return nil
            }

            data.append(byte)
            index = nextIndex
        }

        return data
    }
}
