// OpalHedgeCoreContractConstraintEvaluator~Validation.swift

extension OpalHedgeCoreContractConstraintEvaluator {
    static func validatePositiveInteger(_ value: Int64, name: String) throws {
        guard value > 0 else {
            throw OpalHedgeCoreContractConstraintError.invalidPositiveInteger(
                name: name,
                value: value
            )
        }
    }

    static func validateNonnegativeInteger(_ value: Int64, name: String) throws {
        guard value >= 0 else {
            throw OpalHedgeCoreContractConstraintError.invalidNonnegativeInteger(
                name: name,
                value: value
            )
        }
    }

    static func validateFundingOutputIndex(_ value: Int64, name: String) throws {
        guard value >= 0,
              value <= Int64(UInt32.max) else {
            throw OpalHedgeCoreContractConstraintError.invalidNonnegativeInteger(
                name: name,
                value: value
            )
        }
    }

    static func validateBooleanInteger(_ value: Int64, name: String) throws {
        guard value == 0 || value == 1 else {
            throw OpalHedgeCoreContractConstraintError.invalidBooleanInteger(
                name: name,
                value: value
            )
        }
    }

    static func validateFourBytePositiveScriptInteger(_ value: Int64, name: String) throws {
        try validatePositiveInteger(value, name: name)
        guard value <= OpalHedgeCoreContractConstraintPolicy.maxFourByteScriptInteger else {
            throw OpalHedgeCoreContractConstraintError.invalidPositiveInteger(
                name: name,
                value: value
            )
        }
    }

    static func validatePriceOracleUnits(_ value: Int64, name: String) throws {
        guard value >= OpalHedgeCoreContractConstraintPolicy.minPriceOracleUnitsPerBitcoinCash,
              value <= OpalHedgeCoreContractConstraintPolicy.maxPriceOracleUnitsPerBitcoinCash else {
            throw OpalHedgeCoreContractConstraintError.invalidPositiveInteger(
                name: name,
                value: value
            )
        }
    }

    static func validateMultiplier(_ value: Double, name: String) throws {
        guard value.isFinite, value > 0 else {
            throw OpalHedgeCoreContractConstraintError.invalidLiquidationMultiplier(
                name: name,
                value: value
            )
        }
    }

    static func validateLiquidationRange(
        lowLiquidationPrice: Int64,
        highLiquidationPrice: Int64,
        startPrice: Int64
    ) throws {
        guard lowLiquidationPrice < startPrice else {
            throw OpalHedgeCoreContractConstraintError.lowLiquidationPriceNotBelowStart(
                low: lowLiquidationPrice,
                start: startPrice
            )
        }
        guard highLiquidationPrice > startPrice else {
            throw OpalHedgeCoreContractConstraintError.highLiquidationPriceNotAboveStart(
                high: highLiquidationPrice,
                start: startPrice
            )
        }
    }

    static func validatePayoutSatoshis(_ value: Int64) throws {
        guard value >= OpalHedgeCoreContractConstraintPolicy.dustLimitSatoshis else {
            throw OpalHedgeCoreContractConstraintError.invalidPayoutSatoshis(value)
        }
        guard value <= OpalHedgeCoreContractConstraintPolicy.maxContractSatoshis else {
            throw OpalHedgeCoreContractConstraintError.contractSatoshisExceedMaximum(value)
        }
    }
}
