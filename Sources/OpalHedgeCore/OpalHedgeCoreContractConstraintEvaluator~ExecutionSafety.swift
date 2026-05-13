// OpalHedgeCoreContractConstraintEvaluator~ExecutionSafety.swift

extension OpalHedgeCoreContractConstraintEvaluator {
    static func validateExecutionSafety(
        _ parameters: OpalHedgeCoreContractParameters
    ) throws {
        let satsAtHigh = parameters.nominalUnitsXSatsPerBch / parameters.highLiquidationPrice
        guard satsAtHigh >= OpalHedgeCoreContractConstraintPolicy.minIntegerDivisionPrecisionSteps else {
            throw OpalHedgeCoreContractConstraintError.insufficientDivisionPrecision(
                name: "highLiquidationPrice",
                numerator: parameters.nominalUnitsXSatsPerBch,
                denominator: parameters.highLiquidationPrice
            )
        }

        let satsAtLow = parameters.nominalUnitsXSatsPerBch / parameters.lowLiquidationPrice
        guard satsAtLow <= OpalHedgeCoreContractConstraintPolicy.maxContractSatoshis else {
            throw OpalHedgeCoreContractConstraintError.contractSatoshisExceedMaximum(satsAtLow)
        }

        let extremeLowUnsafeShortSats = satsAtHigh - parameters.satsForNominalUnitsAtHighLiquidation
        guard extremeLowUnsafeShortSats >= 0 else {
            throw OpalHedgeCoreContractConstraintError.unsafeShortPayoutAtHighLiquidation(
                extremeLowUnsafeShortSats
            )
        }

        let extremeLowUnsafeLongSats = parameters.payoutSats
            - satsAtLow
            + parameters.satsForNominalUnitsAtHighLiquidation
        guard extremeLowUnsafeLongSats >= 0 else {
            throw OpalHedgeCoreContractConstraintError.unsafeLongPayoutAtLowLiquidation(
                extremeLowUnsafeLongSats
            )
        }
    }

    static func roundedInt64(_ value: Double, name: String) throws -> Int64 {
        let roundedValue = value.rounded()
        guard roundedValue.isFinite,
              roundedValue > 0,
              roundedValue < Double(Int64.max) else {
            throw OpalHedgeCoreContractConstraintError.invalidRoundedInteger(
                name: name,
                value: value
            )
        }

        return Int64(roundedValue)
    }
}
