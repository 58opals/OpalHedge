// OpalHedgeCoreContractDataDocumentDecodeValidator~Support.swift

import Testing
import OpalHedge

extension OpalHedgeCoreContractDataDocumentDecodeValidator {
    func rejectInvalidContractDataDocumentIntegerFields(
        replacingWithRawJSONValue rawJSONValue: String
    ) throws {
        for fieldPath in integerFieldPaths {
            let jsonText = try OpalHedgeContractDataDocumentMutationTool.makeJsonText(
                replacingFieldAt: fieldPath,
                withRawJSONValue: rawJSONValue,
                in: try makeSourceJsonText(for: fieldPath)
            )
            let error = OpalHedgeTypedErrorCaptureTool.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            OpalHedgeContractDataDocumentErrorExpectationTool.expectInvalidFieldType(
                error,
                at: fieldPath,
                expectedFieldType: "integer"
            )
        }
    }

    var integerFieldPaths: [OpalHedgeContractDataDocumentFieldPathData] {
        [
            .parameter("lowLiquidationPrice"),
            .parameter("highLiquidationPrice"),
            .parameter("startTimestamp"),
            .parameter("maturityTimestamp"),
            .parameter("nominalUnitsXSatsPerBch"),
            .parameter("satsForNominalUnitsAtHighLiquidation"),
            .parameter("payoutSats"),
            .parameter("enableMutualRedemption"),
            .metadata("startPrice"),
            .metadata("durationInSeconds"),
            .metadata("hedgeInputInSatoshis"),
            .metadata("longInputInSatoshis"),
            .metadata("minerCostInSatoshis"),
            .firstFunding("fundingOutputIndex"),
            .firstFunding("fundingSatoshis"),
            .firstFee("satoshis"),
            .firstFundingSettlement("hedgePayoutInSatoshis"),
            .firstFundingSettlement("longPayoutInSatoshis"),
            .firstFundingSettlement("settlementPrice")
        ]
    }

    var numberFieldPaths: [OpalHedgeContractDataDocumentFieldPathData] {
        [
            .metadata("nominalUnits"),
            .metadata("lowLiquidationPriceMultiplier"),
            .metadata("highLiquidationPriceMultiplier"),
            .metadata("hedgeInputInOracleUnits"),
            .metadata("longInputInOracleUnits")
        ]
    }

    func makeSourceJsonText(
        for fieldPath: OpalHedgeContractDataDocumentFieldPathData
    ) throws -> String {
        switch fieldPath {
        case .firstFunding,
            .firstFee,
            .firstFundingSettlement:
            return try makeSettledContractDataDocumentJsonText()
        default:
            return OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
        }
    }

    func makeSettledContractDataDocumentJsonText() throws -> String {
        let document = try OpalHedge.Core.ContractDataDocument(
            draftData: makeSettledDraftData()
        )

        return document.jsonText
    }

    func makeSettledDraftData() throws -> OpalHedge.Core.ContractDraftData {
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
