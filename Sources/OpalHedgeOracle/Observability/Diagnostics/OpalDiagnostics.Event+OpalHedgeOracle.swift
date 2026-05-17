// OpalDiagnostics.Event+OpalHedgeOracle.swift

import OpalDiagnostics

extension OpalDiagnostics.Event {
    static let oracleMessageParsed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.message.parsed")
    static let oracleMessageParseFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.message.parse_failed")
    static let oracleSignatureVerified = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.signature.verified")
    static let oracleSignatureVerificationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.signature.verification_failed")
}
