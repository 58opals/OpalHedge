// OpalHedgeCoreContractSettlementOracleProof.swift

public struct OpalHedgeCoreContractSettlementOracleProof: Sendable, Equatable {
    public let message: OpalHedgeCoreContractOracleMessageData
    public let signature: OpalHedgeCoreContractOracleSignature

    public var messageHex: String {
        message.hex
    }

    public var signatureHex: String {
        signature.hex
    }

    public var messageTimestamp: Int64 {
        message.messageTimestamp
    }

    public var messageSequence: Int64 {
        message.messageSequence
    }

    public var priceSequence: Int64 {
        message.priceSequence
    }

    public var priceValue: Int64 {
        message.priceValue
    }

    package init(
        message: OpalHedgeCoreContractOracleMessageData,
        signature: OpalHedgeCoreContractOracleSignature
    ) {
        self.message = message
        self.signature = signature
    }

    package init(
        messageHex: String,
        signatureHex: String
    ) throws {
        try self.init(
            message: OpalHedgeCoreContractOracleMessageData(
                hex: messageHex,
                messageHexName: "messageHex"
            ),
            signature: OpalHedgeCoreContractOracleSignature(
                hex: signatureHex,
                name: "signatureHex"
            )
        )
    }
}
