// OpalHedgeCoreContractPlannerValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractPlannerValidator {
    @Test("Derives contract plan from creation context")
    func deriveContractPlanFromCreationContext() throws {
        let directPlan = try OpalHedge.Core.ContractPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let plannerPlan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        #expect(directPlan == plannerPlan)
    }

    @Test("Derives contract plan from derivation context")
    func deriveContractPlanFromDerivationContext() throws {
        let context = try OpalHedge.Core.ContractPlanDerivationContext(
            creationContext: OpalHedgeFixtureData.contractCreationContext
        )
        let directPlan = try OpalHedge.Core.ContractPlan(from: context)
        let plannerPlan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        #expect(directPlan == plannerPlan)
    }

    @Test("Derives upstream hedge10week contract parameters")
    func deriveUpstreamHedgeTenWeekContractParameters() throws {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        #expect(plan.parameters == OpalHedgeFixtureData.contractParameters)
    }

    @Test("Derives contract parameters from typed context")
    func deriveContractParametersFromTypedContext() throws {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let fundingAmounts = try OpalHedge.Core.ContractFundingAmounts(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let context = try OpalHedge.Core.ContractPlanDerivationContext(
            creationContext: OpalHedgeFixtureData.contractCreationContext,
            fundingAmounts: fundingAmounts
        )
        let parameters = try OpalHedge.Core.ContractParameters(
            from: context
        )

        #expect(parameters == plan.parameters)
    }

    @Test("Rejects inconsistent parameter funding")
    func rejectInconsistentParameterFunding() {
        let mismatchedContext = OpalHedgeContractFixtureBuilder.makeCreationContext(
            nominalUnits: 900,
            maturityTimestamp: 6_663_643,
            isSimpleHedge: 1,
            highLiquidationPriceMultiplier: 10,
            lowLiquidationPriceMultiplier: 0.75
        )
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            let fundingAmounts = try OpalHedge.Core.ContractFundingAmounts(
                from: mismatchedContext
            )
            _ = try OpalHedge.Core.ContractPlanDerivationContext(
                creationContext: OpalHedgeFixtureData.contractCreationContext,
                fundingAmounts: fundingAmounts
            )
        }

        #expect(
            error == .inconsistentContractFundingAmount(
                name: "nominalUnitsXSatsPerBitcoinCash",
                expected: 100_000_000_000,
                actual: 90_000_000_000
            )
        )
    }

    @Test("Derives upstream hedge10week contract funding amounts")
    func deriveUpstreamHedgeTenWeekContractFundingAmounts() throws {
        let fundingAmounts = try OpalHedge.Core.ContractFundingAmounts(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        #expect(fundingAmounts.lowLiquidationPrice == 17_700)
        #expect(fundingAmounts.highLiquidationPrice == 236_000)
        #expect(fundingAmounts.nominalUnitsXSatsPerBitcoinCash == 100_000_000_000)
        #expect(fundingAmounts.satsForNominalUnitsAtHighLiquidation == 0)
        #expect(fundingAmounts.satsForNominalUnitsAtLowLiquidation == 5_649_717)
        #expect(fundingAmounts.satsForNominalUnitsAtStart == 4_237_288)
        #expect(fundingAmounts.shortInputInSatoshis == 4_237_288)
        #expect(fundingAmounts.longInputInSatoshis == 1_412_429)
        #expect(fundingAmounts.payoutSats == 5_649_717)
    }

    @Test("Derives upstream hedge10week contract metadata")
    func deriveUpstreamHedgeTenWeekContractMetadata() throws {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )

        #expect(plan.metadata.takerSide == .short)
        #expect(plan.metadata.makerSide == .long)
        #expect(plan.metadata.shortPayoutAddress.rawValue == OpalHedgeFixtureData.shortPayoutAddress)
        #expect(plan.metadata.longPayoutAddress.rawValue == OpalHedgeFixtureData.longPayoutAddress)
        #expect(plan.metadata.startingOracleMessageHex == OpalHedgeFixtureData.startingOracleMessageHex)
        #expect(plan.metadata.startingOracleSignatureHex == OpalHedgeFixtureData.startingOracleSignatureHex)
        #expect(plan.metadata.startPrice == 23_600)
        #expect(plan.metadata.durationInSeconds == 6_048_000)
        #expect(plan.metadata.nominalUnits == 1_000)
        #expect(plan.metadata.lowLiquidationPriceMultiplier == 0.75)
        #expect(plan.metadata.highLiquidationPriceMultiplier == 10)
        #expect(plan.metadata.isSimpleHedge == 1)
        #expect(plan.metadata.shortInputInSatoshis == 4_237_288)
        #expect(plan.metadata.longInputInSatoshis == 1_412_429)
        #expect(plan.metadata.minerCostInSatoshis == 632)
        #expect(abs(plan.metadata.shortInputInOracleUnits - 999.999968) < 0.000001)
        #expect(abs(plan.metadata.longInputInOracleUnits - 333.3332444) < 0.000001)
    }

    @Test("Derives contract metadata from typed context")
    func deriveContractMetadataFromTypedContext() throws {
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let fundingAmounts = try OpalHedge.Core.ContractFundingAmounts(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let context = try OpalHedge.Core.ContractPlanDerivationContext(
            creationContext: OpalHedgeFixtureData.contractCreationContext,
            fundingAmounts: fundingAmounts
        )
        let metadata = try OpalHedge.Core.ContractMetadata(
            from: context
        )

        #expect(metadata == plan.metadata)
    }

    @Test("Rejects inconsistent metadata funding")
    func rejectInconsistentMetadataFunding() {
        let mismatchedContext = OpalHedgeContractFixtureBuilder.makeCreationContext(
            nominalUnits: 900,
            maturityTimestamp: 6_663_643,
            isSimpleHedge: 1,
            highLiquidationPriceMultiplier: 10,
            lowLiquidationPriceMultiplier: 0.75
        )
        let error = OpalHedgeTypedErrorCapture.captureConstraintError {
            let fundingAmounts = try OpalHedge.Core.ContractFundingAmounts(
                from: mismatchedContext
            )
            _ = try OpalHedge.Core.ContractPlanDerivationContext(
                creationContext: OpalHedgeFixtureData.contractCreationContext,
                fundingAmounts: fundingAmounts
            )
        }

        #expect(
            error == .inconsistentContractFundingAmount(
                name: "nominalUnitsXSatsPerBitcoinCash",
                expected: 100_000_000_000,
                actual: 90_000_000_000
            )
        )
    }

    @Test("Rejects matching contract sides")
    func rejectMatchingContractSides() {
        let context = OpalHedgeContractFixtureBuilder.makeCreationContext(
            takerSide: .short,
            makerSide: .short,
            nominalUnits: 1_000,
            maturityTimestamp: 6_663_643,
            isSimpleHedge: 1,
            highLiquidationPriceMultiplier: 10,
            lowLiquidationPriceMultiplier: 0.75
        )
        var didThrow = false

        do {
            _ = try OpalHedge.Core.ContractPlanner.createPlan(from: context)
        } catch {
            didThrow = true
        }

        #expect(didThrow)
    }
}
