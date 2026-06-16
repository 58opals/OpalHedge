// OpalHedgeCoreContractConstraintEvaluatorValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractConstraintEvaluatorValidator {
    @Test("Accepts upstream creation context")
    func acceptUpstreamCreationContext() throws {
        try OpalHedge.Core.ContractConstraintEvaluator.validateCreationContext(
            OpalHedgeFixtureData.contractCreationContext
        )
    }

    @Test("Accepts upstream contract parameters")
    func acceptUpstreamContractParameters() throws {
        try OpalHedge.Core.ContractConstraintEvaluator.validateParameters(
            OpalHedgeFixtureData.contractParameters,
            startPrice: 23_600
        )
    }

    @Test("Rejects low liquidation multiplier at start price")
    func rejectLowLiquidationMultiplierAtStartPrice() {
        let context = OpalHedgeContractFixtureBuilder.makeCreationContext(lowLiquidationPriceMultiplier: 1)
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateCreationContext(context)
        }

        #expect(error == .lowLiquidationPriceNotBelowStart(low: 23_600, start: 23_600))
    }

    @Test("Rejects high liquidation multiplier at start price")
    func rejectHighLiquidationMultiplierAtStartPrice() {
        let context = OpalHedgeContractFixtureBuilder.makeCreationContext(highLiquidationPriceMultiplier: 1)
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateCreationContext(context)
        }

        #expect(error == .highLiquidationPriceNotAboveStart(high: 23_600, start: 23_600))
    }

    @Test("Rejects non-binary hedge flag")
    func rejectNonbinaryHedgeFlag() {
        let context = OpalHedgeContractFixtureBuilder.makeCreationContext(isSimpleHedge: 2)
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateCreationContext(context)
        }

        #expect(error == .invalidBooleanInteger(name: "isSimpleHedge", value: 2))
    }

    @Test("Rejects payout below dust")
    func rejectPayoutBelowDust() {
        let parameters = OpalHedgeContractFixtureBuilder.makeParameters(payoutSats: 1_331)
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateParameters(
                parameters,
                startPrice: 23_600
            )
        }

        #expect(error == .invalidPayoutSatoshis(1_331))
    }

    @Test("Rejects insufficient division precision")
    func rejectInsufficientDivisionPrecision() {
        let parameters = OpalHedgeContractFixtureBuilder.makeParameters(
            lowLiquidationPrice: 1,
            highLiquidationPrice: 3,
            nominalUnitsXSatsPerBch: 1_000,
            payoutSats: 1_332
        )
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateParameters(
                parameters,
                startPrice: 2
            )
        }

        #expect(
            error == .insufficientDivisionPrecision(
                name: "highLiquidationPrice",
                numerator: 1_000,
                denominator: 3
            )
        )
    }

    @Test("Rejects rounded integer overflow without trapping")
    func rejectRoundedIntegerOverflowWithoutTrapping() throws {
        let nominalUnits = Double(Int64.max) / Double(
            OpalHedge.Core.ContractConstraintPolicy.satoshisPerBitcoinCash
        )
        let context = OpalHedgeContractFixtureBuilder.makeCreationContext(
            nominalUnits: nominalUnits
        )
        let error = try #require(OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateCreationContext(context)
        })

        guard case .invalidRoundedInteger(let name, let value) = error else {
            Issue.record("Unexpected error: \(error)")
            return
        }

        #expect(name == "nominalUnitsXSatsPerBch")
        #expect(value >= Double(Int64.max))
    }

    @Test("Rejects unsafe long payout at low liquidation")
    func rejectUnsafeLongPayoutAtLowLiquidation() {
        let parameters = OpalHedgeContractFixtureBuilder.makeParameters(payoutSats: 1_332)
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateParameters(
                parameters,
                startPrice: 23_600
            )
        }

        #expect(error == .unsafeLongPayoutAtLowLiquidation(-5_648_385))
    }

    @Test("Rejects derived funding mismatch")
    func rejectDerivedFundingMismatch() {
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateDerivedFunding(
                shortInputInSatoshis: 1,
                longInputInSatoshis: 1,
                payoutSats: 3
            )
        }

        #expect(
            error == .invalidContractFunding(
                shortInput: 1,
                longInput: 1,
                payoutSats: 3
            )
        )
    }

    @Test("Rejects derived funding overflow")
    func rejectDerivedFundingOverflow() {
        let error = OpalHedgeTypedErrorCaptureTool.captureConstraintError {
            try OpalHedge.Core.ContractConstraintEvaluator.validateDerivedFunding(
                shortInputInSatoshis: Int64.max,
                longInputInSatoshis: 1,
                payoutSats: Int64.max
            )
        }

        #expect(
            error == .invalidContractFunding(
                shortInput: Int64.max,
                longInput: 1,
                payoutSats: Int64.max
            )
        )
    }
}
