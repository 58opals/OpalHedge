// OpalHedgeCoreContractConstraintError.swift

public enum OpalHedgeCoreContractConstraintError: Error, Sendable, Equatable {
    case makerSideMustOpposeTaker(taker: OpalHedgeCoreContractSide, maker: OpalHedgeCoreContractSide)
    case invalidPositiveInteger(name: String, value: Int64)
    case invalidNonnegativeInteger(name: String, value: Int64)
    case invalidBooleanInteger(name: String, value: Int64)
    case invalidNominalUnits(Double)
    case invalidLiquidationMultiplier(name: String, value: Double)
    case invalidRoundedInteger(name: String, value: Double)
    case invalidPublicKeyHex(name: String, value: String)
    case invalidTransactionHashHex(name: String, value: String)
    case invalidOracleMessageHex(name: String, value: String)
    case inconsistentOracleMessageComponent(name: String, expected: Int64, actual: Int64)
    case invalidOracleSignatureHex(name: String, value: String)
    case invalidPayoutAddress(name: String, value: String)
    case invalidLockScriptHex(name: String, value: String)
    case unsupportedLockScriptTemplate(name: String, value: String)
    case inconsistentPayoutAddressLockScript(
        name: String,
        addressPublicKeyHashHex: String,
        lockScriptPublicKeyHashHex: String
    )
    case inconsistentPayoutAddressNetwork(
        name: String,
        expectedCashAddrPrefix: String,
        actualCashAddrPrefix: String
    )
    case lowLiquidationPriceNotBelowStart(low: Int64, start: Int64)
    case highLiquidationPriceNotAboveStart(high: Int64, start: Int64)
    case invalidPayoutSatoshis(Int64)
    case contractSatoshisExceedMaximum(Int64)
    case insufficientDivisionPrecision(name: String, numerator: Int64, denominator: Int64)
    case unsafeShortPayoutAtHighLiquidation(Int64)
    case unsafeLongPayoutAtLowLiquidation(Int64)
    case inconsistentContractFundingAmount(name: String, expected: Int64, actual: Int64)
    case invalidContractFunding(shortInput: Int64, longInput: Int64, payoutSats: Int64)
}
