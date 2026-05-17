// OpalDiagnostics.Category+OpalHedge.swift

import OpalDiagnostics

public extension OpalDiagnostics.Category {
    static let contract = OpalDiagnostics.Category(rawValue: "hedge.contract")
    static let dataDocument = OpalDiagnostics.Category(rawValue: "hedge.data_document")
    static let oracle = OpalDiagnostics.Category(rawValue: "hedge.oracle")
    static let bitcoinCash = OpalDiagnostics.Category(rawValue: "hedge.bitcoin_cash")
    static let funding = OpalDiagnostics.Category(rawValue: "hedge.funding")
    static let settlement = OpalDiagnostics.Category(rawValue: "hedge.settlement")
}
