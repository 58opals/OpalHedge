// OpalHedgeCoreContractDataDocument~FundingValidation.swift

extension OpalHedgeCoreContractDataDocument {
    static func validateFundings(
        _ fundings: [OpalHedgeCoreContractFunding]
    ) throws {
        for (index, funding) in fundings.enumerated() {
            let fundingName = "fundings[\(index)]"
            try OpalHedgeCoreContractConstraintEvaluator.validateTransactionHashHex(
                funding.fundingTransactionHash,
                name: "\(fundingName).fundingTransactionHash"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validateNonnegativeInteger(
                funding.fundingOutputIndex,
                name: "\(fundingName).fundingOutputIndex"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validatePositiveInteger(
                funding.fundingSatoshis,
                name: "\(fundingName).fundingSatoshis"
            )

            guard let settlement = funding.settlement else {
                continue
            }

            let settlementName = "\(fundingName).settlement"
            try OpalHedgeCoreContractConstraintEvaluator.validateTransactionHashHex(
                settlement.settlementTransactionHash,
                name: "\(settlementName).settlementTransactionHash"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validatePositiveInteger(
                settlement.shortPayoutInSatoshis,
                name: "\(settlementName).hedgePayoutInSatoshis"
            )
            try OpalHedgeCoreContractConstraintEvaluator.validatePositiveInteger(
                settlement.longPayoutInSatoshis,
                name: "\(settlementName).longPayoutInSatoshis"
            )
            try validateSettlementPayoutTotal(settlement)
            if let settlementPrice = settlement.settlementPrice {
                try OpalHedgeCoreContractConstraintEvaluator.validatePositiveInteger(
                    settlementPrice,
                    name: "\(settlementName).settlementPrice"
                )
            }
            if let settlementMessageHex = settlement.settlementMessageHex {
                try OpalHedgeCoreContractConstraintEvaluator.validateOracleMessageHex(
                    settlementMessageHex,
                    name: "\(settlementName).settlementMessage"
                )
            }
            if let settlementSignatureHex = settlement.settlementSignatureHex {
                try OpalHedgeCoreContractConstraintEvaluator.validateSchnorrSignatureHex(
                    settlementSignatureHex,
                    name: "\(settlementName).settlementSignature"
                )
            }
            if let previousMessageHex = settlement.previousMessageHex {
                try OpalHedgeCoreContractConstraintEvaluator.validateOracleMessageHex(
                    previousMessageHex,
                    name: "\(settlementName).previousMessage"
                )
            }
            if let previousSignatureHex = settlement.previousSignatureHex {
                try OpalHedgeCoreContractConstraintEvaluator.validateSchnorrSignatureHex(
                    previousSignatureHex,
                    name: "\(settlementName).previousSignature"
                )
            }
        }
    }

    private static func validateSettlementPayoutTotal(
        _ settlement: OpalHedgeCoreContractSettlement
    ) throws {
        let total = settlement.shortPayoutInSatoshis.addingReportingOverflow(
            settlement.longPayoutInSatoshis
        )
        guard !total.overflow else {
            throw OpalHedgeCoreContractConstraintError.contractSatoshisExceedMaximum(
                Int64.max
            )
        }
        guard total.partialValue <=
              OpalHedgeCoreContractConstraintPolicy.maxContractSatoshis else {
            throw OpalHedgeCoreContractConstraintError.contractSatoshisExceedMaximum(
                total.partialValue
            )
        }
    }
}
