// OpalHedgeCoreContractDataDocument.swift

import Foundation
import OpalDiagnostics

public struct OpalHedgeCoreContractDataDocument: Sendable, Equatable {
    public let draftData: OpalHedgeCoreContractDraftData
    public let jsonText: String

    public var utf8Data: Data {
        Data(jsonText.utf8)
    }

    public init(draftData: OpalHedgeCoreContractDraftData) throws {
        try self.init(
            draftData: draftData,
            diagnosticsOperation: "encode_data_document",
            successEvent: OpalDiagnostics.Event.dataDocumentEncoded,
            failureEvent: OpalDiagnostics.Event.dataDocumentEncodeFailed
        )
    }

    package init(
        draftData: OpalHedgeCoreContractDraftData,
        diagnosticsOperation: String,
        successEvent: OpalDiagnostics.Event,
        failureEvent: OpalDiagnostics.Event,
        diagnosticsByteCount: Int? = nil,
        extraFields: [OpalDiagnostics.Field] = []
    ) throws {
        do {
            try Self.validateDraftData(draftData)

            let data = try JSONSerialization.data(
                withJSONObject: Self.dictionary(for: draftData),
                options: [.sortedKeys]
            )

            self.draftData = draftData
            self.jsonText = String(decoding: data, as: UTF8.self)
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.dataDocument).record(
                event: successEvent,
                level: .debug,
                fields: Self.diagnosticsFields(
                    operation: diagnosticsOperation,
                    draftData: draftData,
                    byteCount: diagnosticsByteCount ?? data.count,
                    extraFields: extraFields
                )
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.dataDocument).record(
                event: failureEvent,
                level: .error,
                fields: Self.diagnosticsFields(
                    operation: diagnosticsOperation,
                    draftData: draftData,
                    byteCount: diagnosticsByteCount,
                    extraFields: extraFields
                )
                    + OpalDiagnostics.Field.makeConstraintFields(for: error)
                    + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    private static func diagnosticsFields(
        operation: String,
        draftData: OpalHedgeCoreContractDraftData,
        byteCount: Int?,
        extraFields: [OpalDiagnostics.Field]
    ) -> [OpalDiagnostics.Field] {
        var fields: [OpalDiagnostics.Field] = [
            OpalDiagnostics.Field.operationField(operation),
            OpalDiagnostics.Field.moduleField("core"),
            OpalDiagnostics.Field.publicField(
                OpalDiagnostics.Field.fundingCount,
                draftData.fundings.count
            ),
            OpalDiagnostics.Field.publicField(
                OpalDiagnostics.Field.feeCount,
                draftData.fees.count
            ),
            OpalDiagnostics.Field.publicField(
                OpalDiagnostics.Field.payloadType,
                "json"
            )
        ]

        if let byteCount {
            fields.append(
                OpalDiagnostics.Field.publicField(
                    OpalDiagnostics.Field.byteCount,
                    byteCount
                )
            )
        }

        fields.append(contentsOf: extraFields)

        return fields
    }
}
