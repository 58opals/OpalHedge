// OpalHedge+Core.swift

import OpalHedgeCore

extension OpalHedge {
    public enum Core {
        public typealias Context = OpalHedgeCoreContext
        public typealias ContractConstraintError = OpalHedgeCoreContractConstraintError
        public typealias ContractConstraintEvaluator = OpalHedgeCoreContractConstraintEvaluator
        public typealias ContractConstraintPolicy = OpalHedgeCoreContractConstraintPolicy
        public typealias ContractCreationContext = OpalHedgeCoreContractCreationContext
        public typealias ContractDataDocument = OpalHedgeCoreContractDataDocument
        public typealias ContractDataDocumentError = OpalHedgeCoreContractDataDocumentError
        public typealias ContractDraftData = OpalHedgeCoreContractDraftData
        public typealias ContractFeeData = OpalHedgeCoreContractFeeData
        public typealias ContractFunding = OpalHedgeCoreContractFunding
        public typealias ContractFundingAmounts = OpalHedgeCoreContractFundingAmounts
        public typealias ContractMetadata = OpalHedgeCoreContractMetadata
        public typealias ContractOracleMessageData = OpalHedgeCoreContractOracleMessageData
        public typealias ContractOracleSignature = OpalHedgeCoreContractOracleSignature
        public typealias ContractParameters = OpalHedgeCoreContractParameters
        public typealias ContractPlan = OpalHedgeCoreContractPlan
        public typealias ContractPlanDerivationContext = OpalHedgeCoreContractPlanDerivationContext
        public typealias ContractPlanner = OpalHedgeCoreContractPlanner
        public typealias ContractPublicKey = OpalHedgeCoreContractPublicKey
        public typealias ContractLockScript = OpalHedgeCoreContractLockScript
        public typealias ContractPayoutAddress = OpalHedgeCoreContractPayoutAddress
        public typealias ContractPreset = OpalHedgeCoreContractPreset
        public typealias ContractSettlement = OpalHedgeCoreContractSettlement
        public typealias ContractSettlementOracleProof = OpalHedgeCoreContractSettlementOracleProof
        public typealias ContractSettlementPayoutAmounts =
            OpalHedgeCoreContractSettlementPayoutAmounts
        public typealias ContractSide = OpalHedgeCoreContractSide
        public typealias ContractStartingOracleProof = OpalHedgeCoreContractStartingOracleProof
        public typealias SettlementCalculationError = OpalHedgeCoreSettlementCalculationError
        public typealias SettlementCalculator = OpalHedgeCoreSettlementCalculator
        public typealias SettlementCondition = OpalHedgeCoreSettlementCondition
        public typealias SettlementConditionError = OpalHedgeCoreSettlementConditionError
        public typealias SettlementConditionResolver = OpalHedgeCoreSettlementConditionResolver
        public typealias SettlementKind = OpalHedgeCoreSettlementKind
        public typealias SettlementOutcome = OpalHedgeCoreSettlementOutcome
    }
}
