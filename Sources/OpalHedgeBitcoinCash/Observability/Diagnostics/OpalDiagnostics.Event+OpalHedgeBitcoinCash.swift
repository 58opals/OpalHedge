// OpalDiagnostics.Event+OpalHedgeBitcoinCash.swift

import OpalDiagnostics

extension OpalDiagnostics.Event {
    static let contractAddressEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_address.encoded")
    static let contractAddressEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_address.encoding_failed")
    static let contractParametersEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_parameters.encoded")
    static let contractParameterEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_parameters.encoding_failed")
    static let contractScriptEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_script.encoding_failed")
}
