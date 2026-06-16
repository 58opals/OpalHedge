// OpalHedgeCoreContractConstraintEvaluator~DerivedFunding.swift

import OpalDiagnostics

extension OpalHedgeCoreContractConstraintEvaluator {
    public static func validateDerivedFunding(
        shortInputInSatoshis: Int64,
        longInputInSatoshis: Int64,
        payoutSats: Int64
    ) throws {
        do {
            let totalInput = shortInputInSatoshis.addingReportingOverflow(
                longInputInSatoshis
            )
            guard shortInputInSatoshis > 0,
                  longInputInSatoshis > 0,
                  payoutSats > 0,
                  !totalInput.overflow,
                  totalInput.partialValue == payoutSats else {
                throw OpalHedgeCoreContractConstraintError.invalidContractFunding(
                    shortInput: shortInputInSatoshis,
                    longInput: longInputInSatoshis,
                    payoutSats: payoutSats
                )
            }
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintsValidated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_derived_funding"),
                    OpalDiagnostics.Field.moduleField("core"),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.satoshiCount,
                        payoutSats
                    )
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintValidationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_derived_funding"),
                    OpalDiagnostics.Field.moduleField("core")
                ] + OpalDiagnostics.Field.makeConstraintFields(for: error)
                    + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    static func validatePayoutAddress(
        _ address: OpalHedgeCoreContractPayoutAddress,
        matches lockScript: OpalHedgeCoreContractLockScript,
        name: String
    ) throws {
        guard address.publicKeyHashHex == lockScript.publicKeyHashHex else {
            throw OpalHedgeCoreContractConstraintError
                .inconsistentPayoutAddressLockScript(
                    name: name,
                    addressPublicKeyHashHex: address.publicKeyHashHex,
                    lockScriptPublicKeyHashHex: lockScript.publicKeyHashHex
                )
        }
    }

    static func roundedPrice(startPrice: Int64, multiplier: Double, name: String) throws -> Int64 {
        try roundedInt64(Double(startPrice) * multiplier, name: name)
    }

    static func nominalUnitsXSatsPerBitcoinCash(for nominalUnits: Double) throws -> Int64 {
        try roundedInt64(
            nominalUnits * Double(OpalHedgeCoreContractConstraintPolicy.satoshisPerBitcoinCash),
            name: "nominalUnitsXSatsPerBch"
        )
    }
}
