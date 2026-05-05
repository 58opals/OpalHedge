// OpalHedgeCoreContractStartingOracleProof.swift

public struct OpalHedgeCoreContractStartingOracleProof: Sendable, Equatable {
    public let oraclePublicKey: OpalHedgeCoreContractPublicKey
    public let message: OpalHedgeCoreContractOracleMessageData
    public let signature: OpalHedgeCoreContractOracleSignature

    public var oraclePublicKeyHex: String {
        oraclePublicKey.hex
    }

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
        oraclePublicKey: OpalHedgeCoreContractPublicKey,
        message: OpalHedgeCoreContractOracleMessageData,
        signature: OpalHedgeCoreContractOracleSignature
    ) {
        self.oraclePublicKey = oraclePublicKey
        self.message = message
        self.signature = signature
    }

    package init(
        oraclePublicKeyHex: String,
        messageHex: String,
        signatureHex: String,
        messageTimestamp: Int64,
        messageSequence: Int64,
        priceSequence: Int64,
        priceValue: Int64
    ) throws {
        try self.init(
            oraclePublicKey: OpalHedgeCoreContractPublicKey(
                hex: oraclePublicKeyHex,
                name: "oraclePublicKeyHex"
            ),
            message: OpalHedgeCoreContractOracleMessageData(
                hex: messageHex,
                messageTimestamp: messageTimestamp,
                messageSequence: messageSequence,
                priceSequence: priceSequence,
                priceValue: priceValue,
                messageHexName: "messageHex"
            ),
            signature: OpalHedgeCoreContractOracleSignature(
                hex: signatureHex,
                name: "signatureHex"
            )
        )
    }
}
