// OpalHedgeCoreContractDataDocument~MetadataValidation.swift

extension OpalHedgeCoreContractDataDocument {
    static func validateStartingOracleMetadata(
        _ metadata: OpalHedgeCoreContractMetadata,
        matches parameters: OpalHedgeCoreContractParameters
    ) throws {
        let startingOracleMessage = try OpalHedgeCoreContractOracleMessageData(
            hex: metadata.startingOracleMessageHex
        )
        _ = try OpalHedgeCoreContractOracleSignature(
            hex: metadata.startingOracleSignatureHex
        )

        guard metadata.startPrice == startingOracleMessage.priceValue else {
            throw OpalHedgeCoreContractConstraintError
                .inconsistentOracleMessageComponent(
                    name: "startPrice",
                    expected: startingOracleMessage.priceValue,
                    actual: metadata.startPrice
                )
        }
        guard parameters.startTimestamp == startingOracleMessage.messageTimestamp else {
            throw OpalHedgeCoreContractConstraintError
                .inconsistentOracleMessageComponent(
                    name: "startTimestamp",
                    expected: startingOracleMessage.messageTimestamp,
                    actual: parameters.startTimestamp
                )
        }
    }

    static func validateMetadata(
        _ metadata: OpalHedgeCoreContractMetadata,
        matches parameters: OpalHedgeCoreContractParameters
    ) throws {
        guard metadata.makerSide != metadata.takerSide else {
            throw OpalHedgeCoreContractConstraintError.makerSideMustOpposeTaker(
                taker: metadata.takerSide,
                maker: metadata.makerSide
            )
        }

        let expectedDuration = parameters.maturityTimestamp - parameters.startTimestamp
        guard metadata.durationInSeconds == expectedDuration else {
            throw OpalHedgeCoreContractConstraintError
                .inconsistentOracleMessageComponent(
                    name: "durationInSeconds",
                    expected: expectedDuration,
                    actual: metadata.durationInSeconds
                )
        }

        try OpalHedgeCoreContractConstraintEvaluator.validatePayoutAddress(
            metadata.shortPayoutAddress,
            matches: parameters.shortLockScript,
            name: "shortPayoutAddress"
        )
        try OpalHedgeCoreContractConstraintEvaluator.validatePayoutAddress(
            metadata.longPayoutAddress,
            matches: parameters.longLockScript,
            name: "longPayoutAddress"
        )
    }
}
