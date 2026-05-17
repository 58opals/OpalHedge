// OpalDiagnostics.Event+OpalHedge.swift

import OpalDiagnostics

public extension OpalDiagnostics.Event {
    static let contractPlanCreated = OpalDiagnostics.Event(rawValue: "opalhedge.contract.plan.created")
    static let contractPlanCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.contract.plan.creation_failed")
    static let contractConstraintsValidated = OpalDiagnostics.Event(rawValue: "opalhedge.contract.constraints.validated")
    static let contractConstraintValidationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.contract.constraints.validation_failed")

    static let dataDocumentEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.encoded")
    static let dataDocumentEncodeFailed = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.encode_failed")
    static let dataDocumentDecoded = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.decoded")
    static let dataDocumentDecodeFailed = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.decode_failed")

    static let oracleMessageParsed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.message.parsed")
    static let oracleMessageParseFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.message.parse_failed")
    static let oracleSignatureVerified = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.signature.verified")
    static let oracleSignatureVerificationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.signature.verification_failed")
    static let startingOracleProofVerified = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.starting_proof.verified")
    static let startingOracleProofVerificationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.starting_proof.verification_failed")
    static let settlementOracleProofVerified = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.settlement_proof.verified")
    static let settlementOracleProofVerificationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.settlement_proof.verification_failed")

    static let contractAddressEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_address.encoded")
    static let contractAddressEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_address.encoding_failed")
    static let contractParametersEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_parameters.encoded")
    static let contractParameterEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_parameters.encoding_failed")
    static let contractScriptEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_script.encoding_failed")
    static let transactionHashValidationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.transaction_hash.validation_failed")

    static let fundingRequestCreated = OpalDiagnostics.Event(rawValue: "opalhedge.funding.request.created")
    static let fundingRequestCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.funding.request.creation_failed")
    static let fundingRecordCreated = OpalDiagnostics.Event(rawValue: "opalhedge.funding.record.created")
    static let fundingRecordCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.funding.record.creation_failed")

    static let settlementConditionResolved = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.condition.resolved")
    static let settlementConditionResolutionFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.condition.resolution_failed")
    static let settlementPayoutCalculated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.payout.calculated")
    static let settlementPayoutCalculationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.payout.calculation_failed")
    static let settlementRequestCreated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.request.created")
    static let settlementRequestCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.request.creation_failed")
    static let settlementRecordCreated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.record.created")
    static let settlementRecordCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.record.creation_failed")
    static let settlementSummaryCreated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.summary.created")
}
