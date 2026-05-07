// OpalHedgeCoreContractDataDocument~Decode.swift

import Foundation

extension OpalHedgeCoreContractDataDocument {
    public init(jsonText: String) throws {
        try self.init(utf8Data: Data(jsonText.utf8))
    }

    public init(utf8Data: Data) throws {
        let object: Any
        do {
            object = try JSONSerialization.jsonObject(with: utf8Data)
        } catch {
            throw OpalHedgeCoreContractDataDocumentError.invalidJson
        }

        guard let dictionary = object as? [String: Any] else {
            throw OpalHedgeCoreContractDataDocumentError.invalidRootObject
        }

        try self.init(
            draftData: OpalHedgeCoreContractDataDocumentDecoder.draftData(
                from: dictionary
            )
        )
    }
}
