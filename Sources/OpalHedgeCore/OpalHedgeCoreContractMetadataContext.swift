// OpalHedgeCoreContractMetadataContext.swift

package struct OpalHedgeCoreContractMetadataContext: Sendable, Equatable {
    package let creationContext: OpalHedgeCoreContractCreationContext
    package let fundingAmounts: OpalHedgeCoreContractFundingAmounts

    package init(
        creationContext: OpalHedgeCoreContractCreationContext,
        fundingAmounts: OpalHedgeCoreContractFundingAmounts
    ) {
        self.creationContext = creationContext
        self.fundingAmounts = fundingAmounts
    }
}
