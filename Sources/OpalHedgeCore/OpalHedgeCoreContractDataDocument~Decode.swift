// OpalHedgeCoreContractDataDocument~Decode.swift

import Foundation
import OpalDiagnostics

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
            successEvent: OpalDiagnostics.Event.dataDocumentDecoded,
            failureEvent: OpalDiagnostics.Event.dataDocumentDecodeFailed,
            diagnosticsByteCount: utf8Data.count
        )
    }

    private static func recordDecodeFailure(
        _ error: Swift.Error,
        byteCount: Int
    ) {
        OpalDiagnostics.logger(category: OpalDiagnostics.Category.dataDocument).record(
            event: OpalDiagnostics.Event.dataDocumentDecodeFailed,
            level: .error,
            fields: [
                OpalDiagnostics.Field.operationField("decode_data_document"),
                OpalDiagnostics.Field.moduleField("core"),
                OpalDiagnostics.Field.publicField(
                    OpalDiagnostics.Field.byteCount,
                    byteCount
                ),
                OpalDiagnostics.Field.publicField(
                    OpalDiagnostics.Field.payloadType,
                    "json"
                )
            ] + OpalDiagnostics.Field.makeConstraintFields(for: error)
                + OpalDiagnostics.Field.makeErrorFields(for: error)
        )
    }
}
