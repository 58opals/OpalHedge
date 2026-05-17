// OpalHedgeBitcoinCashScriptEncoder.swift

import Foundation
import OpalDiagnostics

public enum OpalHedgeBitcoinCashScriptEncoder {
    public static func encodeScriptNumber(_ value: Int64) -> Data {
        guard value != 0 else {
            return Data()
        }

        let isNegative = value < 0
        var magnitude = isNegative ? UInt64(~value) + 1 : UInt64(value)
        var encodedData = Data()

        while magnitude > 0 {
            encodedData.append(UInt8(magnitude & 0xff))
            magnitude >>= 8
        }

        let lastByte = encodedData[encodedData.index(before: encodedData.endIndex)]
        if lastByte & 0x80 != 0 {
            encodedData.append(isNegative ? 0x80 : 0x00)
        } else if isNegative {
            let signIndex = encodedData.index(before: encodedData.endIndex)
            encodedData[signIndex] |= 0x80
        }

        return encodedData
    }

    public static func encodeScriptNumberPush(_ value: Int64) throws -> Data {
        try encodeDataPush(encodeScriptNumber(value))
    }

    public static func encodeDataPush(_ data: Data) throws -> Data {
        do {
            guard data.count <= UInt32.max else {
                throw OpalHedgeBitcoinCashScriptEncodingError.dataPushTooLarge(data.count)
            }

            if let smallIntegerPushOpcode = makeSmallIntegerPushOpcode(for: data) {
                return Data([smallIntegerPushOpcode])
            }

            var encodedData = Data()
            encodedData.reserveCapacity(data.count + 5)

            switch data.count {
            case 0...75:
                encodedData.append(UInt8(data.count))
            case 76...Int(UInt8.max):
                encodedData.append(opPushData1)
                encodedData.append(UInt8(data.count))
            case (Int(UInt8.max) + 1)...Int(UInt16.max):
                encodedData.append(opPushData2)
                encodedData.append(UInt8(data.count & 0xff))
                encodedData.append(UInt8((data.count >> 8) & 0xff))
            default:
                encodedData.append(opPushData4)
                encodedData.append(UInt8(data.count & 0xff))
                encodedData.append(UInt8((data.count >> 8) & 0xff))
                encodedData.append(UInt8((data.count >> 16) & 0xff))
                encodedData.append(UInt8((data.count >> 24) & 0xff))
            }

            encodedData.append(data)
            return encodedData
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractScriptEncodingFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("encode_data_push"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        "script_data"
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.byteCount,
                        data.count
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static let op0: UInt8 = 0x00
    private static let op1Negate: UInt8 = 0x4f
    private static let op1: UInt8 = 0x51
    private static let opPushData1: UInt8 = 0x4c
    private static let opPushData2: UInt8 = 0x4d
    private static let opPushData4: UInt8 = 0x4e

    private static func makeSmallIntegerPushOpcode(for data: Data) -> UInt8? {
        guard data.count <= 1 else {
            return nil
        }

        guard let value = data.first else {
            return op0
        }

        switch value {
        case 0x01...0x10:
            return op1 + value - 1
        case 0x81:
            return op1Negate
        default:
            return nil
        }
    }
}
