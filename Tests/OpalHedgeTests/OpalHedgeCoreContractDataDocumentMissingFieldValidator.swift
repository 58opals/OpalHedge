// OpalHedgeCoreContractDataDocumentMissingFieldValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentMissingFieldValidator {
    @Test("Rejects missing contract data document top-level fields")
    func rejectMissingContractDataDocumentTopLevelFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPath] = [
            .topLevel("parameters"),
            .topLevel("metadata"),
            .topLevel("fundings"),
            .topLevel("fees")
        ]

        for fieldPath in fieldPaths {
            let jsonText = try OpalHedgeContractDataDocumentJSONMutation.jsonText(
                removingFieldAt: fieldPath,
                from: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
            )
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectation.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document parameter fields")
    func rejectMissingContractDataDocumentParameterFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPath] = [
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
            let jsonText = try OpalHedgeContractDataDocumentJSONMutation.jsonText(
                removingFieldAt: fieldPath,
                from: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
            )
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectation.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document metadata fields")
    func rejectMissingContractDataDocumentMetadataFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPath] = [
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
            let jsonText = try OpalHedgeContractDataDocumentJSONMutation.jsonText(
                removingFieldAt: fieldPath,
                from: OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
            )
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectation.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document funding fields")
    func rejectMissingContractDataDocumentFundingFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPath] = [
            .firstFunding("fundingTransactionHash"),
            .firstFunding("fundingOutputIndex"),
            .firstFunding("fundingSatoshis")
        ]
        let jsonText = try settledContractDataDocumentJsonText()

        for fieldPath in fieldPaths {
            let invalidJsonText = try OpalHedgeContractDataDocumentJSONMutation.jsonText(
                removingFieldAt: fieldPath,
                from: jsonText
            )
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: invalidJsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectation.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document fee fields")
    func rejectMissingContractDataDocumentFeeFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPath] = [
            .firstFee("name"),
            .firstFee("description"),
            .firstFee("address"),
            .firstFee("satoshis")
        ]
        let jsonText = try settledContractDataDocumentJsonText()

        for fieldPath in fieldPaths {
            let invalidJsonText = try OpalHedgeContractDataDocumentJSONMutation.jsonText(
                removingFieldAt: fieldPath,
                from: jsonText
            )
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: invalidJsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectation.expectMissingField(
                error,
                at: fieldPath
            )
        }
    }

    @Test("Rejects missing contract data document settlement required fields")
    func rejectMissingContractDataDocumentSettlementRequiredFields() throws {
        let fieldPaths: [OpalHedgeContractDataDocumentFieldPath] = [
            .firstFundingSettlement("settlementType"),
            .firstFundingSettlement("settlementTransactionHash"),
            .firstFundingSettlement("hedgePayoutInSatoshis"),
            .firstFundingSettlement("longPayoutInSatoshis")
        ]
        let jsonText = try settledContractDataDocumentJsonText()

        for fieldPath in fieldPaths {
            let invalidJsonText = try OpalHedgeContractDataDocumentJSONMutation.jsonText(
                removingFieldAt: fieldPath,
                from: jsonText
            )
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: invalidJsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectation.expectMissingField(
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
            let decodedJsonText = try OpalHedgeContractDataDocumentJSONMutation.jsonText(
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

    private func expectMissingOptionalSettlementField(
        _ fieldName: String,
        in settlement: OpalHedge.Core.ContractSettlement
    ) throws {
        switch fieldName {
        case "settlementMessage":
            #expect(settlement.settlementMessageHex == nil)
        case "settlementSignature":
            #expect(settlement.settlementSignatureHex == nil)
        case "previousMessage":
            #expect(settlement.previousMessageHex == nil)
        case "previousSignature":
            #expect(settlement.previousSignatureHex == nil)
        case "settlementPrice":
            #expect(settlement.settlementPrice == nil)
        default:
            try #require(Bool(false))
        }
    }

    private func settledContractDataDocumentJsonText() throws -> String {
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: makeSettledDraftData()
        )

        return document.jsonText
    }

    private func makeSettledDraftData() throws -> OpalHedge.Core.ContractDraftData {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        return OpalHedge.Core.ContractDraftData(
            plan: plan,
            fundings: [
                OpalHedge.Core.ContractFunding(
                    fundingTransactionHash: String(repeating: "1", count: 64),
                    fundingOutputIndex: 1,
                    fundingSatoshis: 5_651_049,
                    settlement: OpalHedge.Core.ContractSettlement(
                        kind: .maturation,
                        settlementTransactionHash: String(repeating: "2", count: 64),
                        shortPayoutInSatoshis: 4_237_288,
                        longPayoutInSatoshis: 1_412_429,
                        settlementMessageHex: OpalHedgeFixtureData.startingOracleMessageHex,
                        settlementSignatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
                        previousMessageHex: OpalHedgeFixtureData.startingOracleMessageHex,
                        previousSignatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
                        settlementPrice: 23_600
                    )
                )
            ],
            fees: [
                OpalHedge.Core.ContractFeeData(
                    name: "settlement",
                    description: "Settlement service fee",
                    address: OpalHedgeFixtureData.longPayoutAddress,
                    satoshis: 1_000
                )
            ]
        )
    }
}
