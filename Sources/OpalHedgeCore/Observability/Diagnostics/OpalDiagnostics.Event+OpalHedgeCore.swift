// OpalDiagnostics.Event+OpalHedgeCore.swift

import OpalDiagnostics

extension OpalDiagnostics.Event {
    static let contractPlanCreated = OpalDiagnostics.Event(rawValue: "opalhedge.contract.plan.created")
    static let contractPlanCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.contract.plan.creation_failed")
    static let contractConstraintsValidated = OpalDiagnostics.Event(rawValue: "opalhedge.contract.constraints.validated")
    static let contractConstraintValidationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.contract.constraints.validation_failed")
    static let dataDocumentEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.encoded")
    static let dataDocumentEncodeFailed = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.encode_failed")
    static let dataDocumentDecoded = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.decoded")
    static let dataDocumentDecodeFailed = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.decode_failed")
    static let settlementConditionResolved = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.condition.resolved")
    static let settlementConditionResolutionFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.condition.resolution_failed")
    static let settlementPayoutCalculated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.payout.calculated")
    static let settlementPayoutCalculationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.payout.calculation_failed")
}
