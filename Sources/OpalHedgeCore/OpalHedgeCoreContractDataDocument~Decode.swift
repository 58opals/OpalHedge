// OpalHedgeCoreContractDataDocument~Decode.swift

import Foundation

extension OpalHedgeCoreContractDataDocument {
    public init(jsonText: String) throws {
        try self.init(utf8Data: Data(jsonText.utf8))
    }

    public init(utf8Data: Data) throws {
        let dictionary: [String: Any]
        do {
            let object = try JSONSerialization.jsonObject(with: utf8Data)
            guard let parsedDictionary = object as? [String: Any] else {
                throw OpalHedgeCoreContractDataDocumentError.invalidRootObject
            }
            dictionary = parsedDictionary
        } catch {
            let documentError = error is OpalHedgeCoreContractDataDocumentError
                ? error
                : OpalHedgeCoreContractDataDocumentError.invalidJson
            Self.recordDecodeFailure(documentError, byteCount: utf8Data.count)
            throw documentError
        }

        let draftData: OpalHedgeCoreContractDraftData
        do {
            draftData = try OpalHedgeCoreContractDataDocumentDecoder.draftData(
                from: dictionary
            )
        } catch {
            Self.recordDecodeFailure(error, byteCount: utf8Data.count)
            throw error
        }

        try self.init(
            draftData: draftData,
            diagnosticsOperation: "decode_data_document",
            successEvent: OpalHedgeCoreDiagnostics.Event.dataDocumentDecoded,
            failureEvent: OpalHedgeCoreDiagnostics.Event.dataDocumentDecodeFailed,
            diagnosticsByteCount: utf8Data.count
        )
    }

    private static func recordDecodeFailure(
        _ error: Swift.Error,
        byteCount: Int
    ) {
        OpalHedgeCoreDiagnostics.record(
            OpalHedgeCoreDiagnostics.Event.dataDocumentDecodeFailed,
            category: OpalHedgeCoreDiagnostics.Category.dataDocument,
            level: .error,
            fields: [
                OpalHedgeCoreDiagnostics.operationField("decode_data_document"),
                OpalHedgeCoreDiagnostics.moduleField("core"),
                OpalHedgeCoreDiagnostics.publicField(
                    OpalHedgeCoreDiagnostics.Field.byteCount,
                    byteCount
                ),
                OpalHedgeCoreDiagnostics.publicField(
                    OpalHedgeCoreDiagnostics.Field.payloadType,
                    "json"
                )
            ] + OpalHedgeCoreDiagnostics.makeConstraintFields(for: error)
                + OpalHedgeCoreDiagnostics.makeErrorFields(for: error)
        )
    }
}
