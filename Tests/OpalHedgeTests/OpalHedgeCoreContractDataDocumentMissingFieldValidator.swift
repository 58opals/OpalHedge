// OpalHedgeCoreContractDataDocumentMissingFieldValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentMissingFieldValidator {
    @Test("Rejects missing contract data document top-level fields")
    func rejectMissingContractDataDocumentTopLevelFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPathData] = [
            .topLevel("parameters"),
            .topLevel("metadata"),
            .topLevel("fundings"),
            .topLevel("fees")
        ]

        for fieldPath in fieldPaths {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                removingFieldAt: fieldPath,
                from: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document parameter fields")
    func rejectMissingContractDataDocumentParameterFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPathData] = [
            .parameter("oraclePublicKey"),
            .parameter("lowLiquidationPrice"),
            .parameter("highLiquidationPrice"),
            .parameter("startTimestamp"),
            .parameter("maturityTimestamp"),
            .parameter("nominalUnitsXSatsPerBch"),
            .parameter("satsForNominalUnitsAtHighLiquidation"),
            .parameter("payoutSats"),
            .parameter("hedgeLockScript"),
            .parameter("longLockScript"),
            .parameter("enableMutualRedemption"),
            .parameter("hedgeMutualRedeemPublicKey"),
            .parameter("longMutualRedeemPublicKey")
        ]

        for fieldPath in fieldPaths {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                removingFieldAt: fieldPath,
                from: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document metadata fields")
    func rejectMissingContractDataDocumentMetadataFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPathData] = [
            .metadata("startingOracleMessage"),
            .metadata("startingOracleSignature"),
            .metadata("takerSide"),
            .metadata("makerSide"),
            .metadata("hedgePayoutAddress"),
            .metadata("longPayoutAddress"),
            .metadata("startPrice"),
            .metadata("durationInSeconds"),
            .metadata("nominalUnits"),
            .metadata("lowLiquidationPriceMultiplier"),
            .metadata("highLiquidationPriceMultiplier"),
            .metadata("hedgeInputInOracleUnits"),
            .metadata("longInputInOracleUnits"),
            .metadata("hedgeInputInSatoshis"),
            .metadata("longInputInSatoshis"),
            .metadata("minerCostInSatoshis")
        ]

        for fieldPath in fieldPaths {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                removingFieldAt: fieldPath,
                from: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document funding fields")
    func rejectMissingContractDataDocumentFundingFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPathData] = [
            .firstFunding("fundingTransactionHash"),
            .firstFunding("fundingOutputIndex"),
            .firstFunding("fundingSatoshis")
        ]
        let jsonText = try settledContractDataDocumentJsonText()

        for fieldPath in fieldPaths {
            let invalidJsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                removingFieldAt: fieldPath,
                from: jsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: invalidJsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document fee fields")
    func rejectMissingContractDataDocumentFeeFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPathData] = [
            .firstFee("name"),
            .firstFee("description"),
            .firstFee("address"),
            .firstFee("satoshis")
        ]
        let jsonText = try settledContractDataDocumentJsonText()

        for fieldPath in fieldPaths {
            let invalidJsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                removingFieldAt: fieldPath,
                from: jsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: invalidJsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document settlement required fields")
    func rejectMissingContractDataDocumentSettlementRequiredFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPathData] = [
            .firstFundingSettlement("settlementType"),
            .firstFundingSettlement("settlementTransactionHash"),
            .firstFundingSettlement("hedgePayoutInSatoshis"),
            .firstFundingSettlement("longPayoutInSatoshis")
        ]
        let jsonText = try settledContractDataDocumentJsonText()

        for fieldPath in fieldPaths {
            let invalidJsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                removingFieldAt: fieldPath,
                from: jsonText
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: invalidJsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Allows missing contract data document settlement optional fields")
    func allowMissingContractDataDocumentSettlementOptionalFields() throws {
        let fields = [
            "settlementMessage",
            "settlementSignature",
            "previousMessage",
            "previousSignature",
            "settlementPrice"
        ]
        let jsonText = try settledContractDataDocumentJsonText()

        for fieldName in fields {
            let decodedJsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                removingFieldAt: .firstFundingSettlement(fieldName),
                from: jsonText
            )
            let document = try OpalHedge.Core.ContractDataDocument(
                jsonText: decodedJsonText
            )
            let funding = try #require(document.draftData.fundings.first)
            let settlement = try #require(funding.settlement)

            try expectMissingOptionalSettlementField(fieldName, in: settlement)
        }
    }
}
