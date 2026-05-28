// OpalHedgeOraclePriceMessage.swift

import Foundation
import OpalDiagnostics

public struct OpalHedgeOraclePriceMessage: Sendable, Equatable {
    public let rawData: Data
    public let messageTimestamp: Int64
    public let messageSequence: Int64
    public let priceSequence: Int64
    public let priceValue: Int64

    public init(
        rawData: Data,
        messageTimestamp: Int64,
        messageSequence: Int64,
        priceSequence: Int64,
        priceValue: Int64
    ) {
        self.rawData = rawData
        self.messageTimestamp = messageTimestamp
        self.messageSequence = messageSequence
        self.priceSequence = priceSequence
        self.priceValue = priceValue
    }

    public static func parse(hex text: String) throws -> Self {
        let data: Data
        do {
            data = try OpalHedgeOracleHexadecimalCodec.decode(text)
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                event: OpalDiagnostics.Event.oracleMessageParseFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("parse_oracle_message"),
                    OpalDiagnostics.Field.moduleField("oracle"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        "hex"
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.byteCount,
                        text.utf8.count
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }

        return try parse(data: data)
    }

    public static func parse(data: Data) throws -> Self {
        do {
            let message = try parseValidatedData(data)
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                event: OpalDiagnostics.Event.oracleMessageParsed,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("parse_oracle_message"),
                    OpalDiagnostics.Field.moduleField("oracle"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        "bytes"
                    )
                ] + OpalDiagnostics.Field.makeMessageFields(for: message)
            )
            return message
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                event: OpalDiagnostics.Event.oracleMessageParseFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("parse_oracle_message"),
                    OpalDiagnostics.Field.moduleField("oracle"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        "bytes"
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

    public var hex: String {
        OpalHedgeOracleHexadecimalCodec.encode(rawData)
    }

    var isCanonical: Bool {
        (try? Self.parseValidatedData(rawData)) == self
    }

    private static func parseValidatedData(_ data: Data) throws -> Self {
        let expectedLength = 16
        guard data.count == expectedLength else {
            throw OpalHedgeOracleMessageError.invalidMessageLength(
                expected: expectedLength,
                actual: data.count
            )
        }

        let bytes = [UInt8](data)
        let messageTimestamp = Int64(readInt32LittleEndian(from: bytes, offset: 0))
        let messageSequence = Int64(readInt32LittleEndian(from: bytes, offset: 4))
        let priceSequence = Int64(readInt32LittleEndian(from: bytes, offset: 8))
        let priceValue = Int64(readInt32LittleEndian(from: bytes, offset: 12))

        try validatePositiveScriptInteger(messageTimestamp, name: "messageTimestamp")
        try validatePositiveScriptInteger(messageSequence, name: "messageSequence")
        try validatePositiveScriptInteger(priceSequence, name: "priceSequence")
        try validatePositiveScriptInteger(priceValue, name: "priceValue")

        return Self(
            rawData: data,
            messageTimestamp: messageTimestamp,
            messageSequence: messageSequence,
            priceSequence: priceSequence,
            priceValue: priceValue
        )
    }

    private static func readInt32LittleEndian(from bytes: [UInt8], offset: Int) -> Int32 {
        let value = UInt32(bytes[offset])
            | UInt32(bytes[offset + 1]) << 8
            | UInt32(bytes[offset + 2]) << 16
            | UInt32(bytes[offset + 3]) << 24

        return Int32(bitPattern: value)
    }

    private static func validatePositiveScriptInteger(_ value: Int64, name: String) throws {
        guard value > 0, value <= Int64(Int32.max) else {
            throw OpalHedgeOracleMessageError.invalidScriptInteger(name: name, value: value)
        }
    }
}
