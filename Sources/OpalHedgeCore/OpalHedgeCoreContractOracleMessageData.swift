// OpalHedgeCoreContractOracleMessageData.swift

public struct OpalHedgeCoreContractOracleMessageData: Sendable, Equatable {
    public let hex: String
    public let messageTimestamp: Int64
    public let messageSequence: Int64
    public let priceSequence: Int64
    public let priceValue: Int64

    public init(hex: String) throws {
        try self.init(hex: hex, messageHexName: "hex")
    }

    public init(
        hex: String,
        messageTimestamp: Int64,
        messageSequence: Int64,
        priceSequence: Int64,
        priceValue: Int64
    ) throws {
        try self.init(
            hex: hex,
            messageTimestamp: messageTimestamp,
            messageSequence: messageSequence,
            priceSequence: priceSequence,
            priceValue: priceValue,
            messageHexName: "hex"
        )
    }

    package init(hex: String, messageHexName: String) throws {
        let decodedFields = try Self.decodeFields(hex: hex, messageHexName: messageHexName)

        self.hex = hex
        self.messageTimestamp = decodedFields.messageTimestamp
        self.messageSequence = decodedFields.messageSequence
        self.priceSequence = decodedFields.priceSequence
        self.priceValue = decodedFields.priceValue
    }

    package init(
        hex: String,
        messageTimestamp: Int64,
        messageSequence: Int64,
        priceSequence: Int64,
        priceValue: Int64,
        messageHexName: String
    ) throws {
        let decodedFields = try Self.decodeFields(hex: hex, messageHexName: messageHexName)
        try Self.validateComponent(
            messageTimestamp,
            expected: decodedFields.messageTimestamp,
            name: "messageTimestamp"
        )
        try Self.validateComponent(
            messageSequence,
            expected: decodedFields.messageSequence,
            name: "messageSequence"
        )
        try Self.validateComponent(
            priceSequence,
            expected: decodedFields.priceSequence,
            name: "priceSequence"
        )
        try Self.validateComponent(
            priceValue,
            expected: decodedFields.priceValue,
            name: "priceValue"
        )

        self.hex = hex
        self.messageTimestamp = decodedFields.messageTimestamp
        self.messageSequence = decodedFields.messageSequence
        self.priceSequence = decodedFields.priceSequence
        self.priceValue = decodedFields.priceValue
    }

    private static func decodeFields(
        hex: String,
        messageHexName: String
    ) throws -> (
        messageTimestamp: Int64,
        messageSequence: Int64,
        priceSequence: Int64,
        priceValue: Int64
    ) {
        try OpalHedgeCoreContractConstraintEvaluator.validateOracleMessageHex(
            hex,
            name: messageHexName
        )

        let bytes = decodeBytes(hex)
        let messageTimestamp = readInt32LittleEndian(bytes, offset: 0)
        let messageSequence = readInt32LittleEndian(bytes, offset: 4)
        let priceSequence = readInt32LittleEndian(bytes, offset: 8)
        let priceValue = readInt32LittleEndian(bytes, offset: 12)

        try OpalHedgeCoreContractConstraintEvaluator.validateFourBytePositiveScriptInteger(
            messageTimestamp,
            name: "messageTimestamp"
        )
        try OpalHedgeCoreContractConstraintEvaluator.validateFourBytePositiveScriptInteger(
            messageSequence,
            name: "messageSequence"
        )
        try OpalHedgeCoreContractConstraintEvaluator.validateFourBytePositiveScriptInteger(
            priceSequence,
            name: "priceSequence"
        )
        try OpalHedgeCoreContractConstraintEvaluator.validateFourBytePositiveScriptInteger(
            priceValue,
            name: "priceValue"
        )

        return (
            messageTimestamp: messageTimestamp,
            messageSequence: messageSequence,
            priceSequence: priceSequence,
            priceValue: priceValue
        )
    }

    private static func validateComponent(
        _ value: Int64,
        expected: Int64,
        name: String
    ) throws {
        guard value == expected else {
            throw OpalHedgeCoreContractConstraintError.inconsistentOracleMessageComponent(
                name: name,
                expected: expected,
                actual: value
            )
        }
    }

    private static func decodeBytes(_ hex: String) -> [UInt8] {
        let characters = Array(hex.utf8)
        var bytes: [UInt8] = []
        bytes.reserveCapacity(characters.count / 2)

        for index in stride(from: 0, to: characters.count, by: 2) {
            let highNibble = decodeHexNibble(characters[index])
            let lowNibble = decodeHexNibble(characters[index + 1])
            bytes.append(highNibble << 4 | lowNibble)
        }

        return bytes
    }

    private static func decodeHexNibble(_ character: UInt8) -> UInt8 {
        if character >= UInt8(ascii: "0"), character <= UInt8(ascii: "9") {
            return character - UInt8(ascii: "0")
        }

        return character - UInt8(ascii: "a") + 10
    }

    private static func readInt32LittleEndian(_ bytes: [UInt8], offset: Int) -> Int64 {
        let value = UInt32(bytes[offset])
            | UInt32(bytes[offset + 1]) << 8
            | UInt32(bytes[offset + 2]) << 16
            | UInt32(bytes[offset + 3]) << 24

        return Int64(Int32(bitPattern: value))
    }
}
