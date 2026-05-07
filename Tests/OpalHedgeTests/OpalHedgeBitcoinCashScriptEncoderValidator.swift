// OpalHedgeBitcoinCashScriptEncoderValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeBitcoinCashScriptEncoderValidator {
    @Test("Encodes minimally serialized Script numbers")
    func encodeMinimallySerializedScriptNumbers() {
        let vectors: [(Int64, [UInt8])] = [
            (0, []),
            (1, [0x01]),
            (-1, [0x81]),
            (16, [0x10]),
            (127, [0x7f]),
            (128, [0x80, 0x00]),
            (-128, [0x80, 0x80]),
            (255, [0xff, 0x00]),
            (-255, [0xff, 0x80]),
            (256, [0x00, 0x01])
        ]

        for (value, expectedBytes) in vectors {
            let encodedData = OpalHedge.BitcoinCash.ScriptEncoder
                .encodeScriptNumber(value)

            #expect(encodedData == Data(expectedBytes))
        }
    }

    @Test("Encodes minimally serialized Script number pushes")
    func encodeMinimallySerializedScriptNumberPushes() throws {
        let vectors: [(Int64, [UInt8])] = [
            (0, [0x00]),
            (1, [0x51]),
            (-1, [0x4f]),
            (16, [0x60]),
            (17, [0x01, 0x11]),
            (128, [0x02, 0x80, 0x00])
        ]

        for (value, expectedBytes) in vectors {
            let encodedData = try OpalHedge.BitcoinCash.ScriptEncoder
                .encodeScriptNumberPush(value)

            #expect(encodedData == Data(expectedBytes))
        }
    }

    @Test("Encodes minimal data push opcodes")
    func encodeMinimalDataPushOpcodes() throws {
        let directPushData = Data(repeating: 0xaa, count: 75)
        let pushData1 = Data(repeating: 0xbb, count: 76)
        let pushData2 = Data(repeating: 0xcc, count: 256)
        let pushData4 = Data(repeating: 0xdd, count: 65_536)

        #expect(try OpalHedge.BitcoinCash.ScriptEncoder.encodeDataPush(Data()) == Data([0x00]))
        #expect(try OpalHedge.BitcoinCash.ScriptEncoder.encodeDataPush(Data([0x01])) == Data([0x51]))
        #expect(try OpalHedge.BitcoinCash.ScriptEncoder.encodeDataPush(Data([0x81])) == Data([0x4f]))
        #expect(try OpalHedge.BitcoinCash.ScriptEncoder.encodeDataPush(Data([0x51])) == Data([0x01, 0x51]))

        var directPushExpectedData = Data([0x4b])
        directPushExpectedData.append(directPushData)
        #expect(try OpalHedge.BitcoinCash.ScriptEncoder.encodeDataPush(directPushData) == directPushExpectedData)

        var pushData1ExpectedData = Data([0x4c, 0x4c])
        pushData1ExpectedData.append(pushData1)
        #expect(try OpalHedge.BitcoinCash.ScriptEncoder.encodeDataPush(pushData1) == pushData1ExpectedData)

        var pushData2ExpectedData = Data([0x4d, 0x00, 0x01])
        pushData2ExpectedData.append(pushData2)
        #expect(try OpalHedge.BitcoinCash.ScriptEncoder.encodeDataPush(pushData2) == pushData2ExpectedData)

        var pushData4ExpectedData = Data([0x4e, 0x00, 0x00, 0x01, 0x00])
        pushData4ExpectedData.append(pushData4)
        #expect(try OpalHedge.BitcoinCash.ScriptEncoder.encodeDataPush(pushData4) == pushData4ExpectedData)
    }
}
