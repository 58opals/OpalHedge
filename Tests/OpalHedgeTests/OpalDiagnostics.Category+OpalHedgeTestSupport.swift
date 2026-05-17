// OpalDiagnostics.Category+OpalHedgeTestSupport.swift

import OpalDiagnostics

extension OpalDiagnostics.Category {
    var isOpalHedgeCategory: Bool {
        self == OpalDiagnostics.Category.hedge
            || rawValue.hasPrefix("hedge.")
    }
}
