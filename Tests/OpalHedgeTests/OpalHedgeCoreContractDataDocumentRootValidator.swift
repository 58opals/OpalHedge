// OpalHedgeCoreContractDataDocumentRootValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeCoreContractDataDocumentRootValidator {
    @Test("Rejects malformed contract data document JSON text")
    func rejectMalformedContractDataDocumentJsonText() {
        let jsonTexts = [
            "",
            "{",
            #"{"parameters":}"#
        ]

        for jsonText in jsonTexts {
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            #expect(error == .invalidJson)
        }
    }

    @Test("Rejects non-finite contract data document JSON numbers")
    func rejectNonFiniteContractDataDocumentJsonNumbers() {
        let jsonText = OpalHedgeFixtureData.upstreamHedgeTenWeekContractDataDocumentJsonText
            .replacingOccurrences(
                of: #""nominalUnits":1000"#,
                with: #""nominalUnits":1e999"#
            )
        let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
            _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
        }

        #expect(error == .invalidJson)
    }

    @Test("Rejects malformed contract data document UTF8 data")
    func rejectMalformedContractDataDocumentUTF8Data() {
        let utf8DataValues = [
            Data(),
            Data("{".utf8),
            Data(#"{"parameters":}"#.utf8)
        ]

        for utf8Data in utf8DataValues {
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(utf8Data: utf8Data)
            }

            #expect(error == .invalidJson)
        }
    }

    @Test("Rejects contract data document JSON with invalid root object")
    func rejectContractDataDocumentJsonWithInvalidRootObject() {
        let jsonTexts = [
            "[]",
            #"[{"parameters":{}}]"#
        ]

        for jsonText in jsonTexts {
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(jsonText: jsonText)
            }

            #expect(error == .invalidRootObject)
        }
    }

    @Test("Rejects contract data document UTF8 data with invalid root object")
    func rejectContractDataDocumentUTF8DataWithInvalidRootObject() {
        let utf8DataValues = [
            Data("[]".utf8),
            Data(#"[{"parameters":{}}]"#.utf8)
        ]

        for utf8Data in utf8DataValues {
            let error = OpalHedgeTypedErrorCapture.captureContractDataDocumentError {
                _ = try OpalHedge.Core.ContractDataDocument(utf8Data: utf8Data)
            }

            #expect(error == .invalidRootObject)
        }
    }
}
