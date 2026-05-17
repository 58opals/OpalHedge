// OpalDiagnostics.Category+OpalHedgeCore.swift

import OpalDiagnostics

extension OpalDiagnostics.Category {
    static let contract = OpalDiagnostics.Category(rawValue: "hedge.contract")
    static let dataDocument = OpalDiagnostics.Category(rawValue: "hedge.data_document")
    static let settlement = OpalDiagnostics.Category(rawValue: "hedge.settlement")
}
