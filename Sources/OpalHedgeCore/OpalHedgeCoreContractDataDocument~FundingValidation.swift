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
            try OpalHedgeCoreContractConstraintEvaluator.validateFundingOutputIndex(
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
            try OpalHedgeCoreContractConstraintEvaluator.validatePayoutSatoshis(
                settlement.shortPayoutInSatoshis,
            )
            try OpalHedgeCoreContractConstraintEvaluator.validatePayoutSatoshis(
                settlement.longPayoutInSatoshis,
            )
            try validateSettlementPayoutTotal(
                settlement,
                fundingSatoshis: funding.fundingSatoshis
            )
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
        _ settlement: OpalHedgeCoreContractSettlement,
        fundingSatoshis: Int64
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
        guard total.partialValue <= fundingSatoshis else {
            throw OpalHedgeCoreContractConstraintError.invalidContractFunding(
                shortInput: settlement.shortPayoutInSatoshis,
                longInput: settlement.longPayoutInSatoshis,
                payoutSats: fundingSatoshis
            )
        }
    }
}
