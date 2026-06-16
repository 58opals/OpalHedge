// OpalDiagnosticsIntegrationValidator+Support.swift

import Foundation
import OpalDiagnostics
import OpalHedgeBitcoinCash

extension OpalDiagnosticsIntegrationValidator {
    static let diagnosticsConfiguration = OpalDiagnostics.Configuration(
        minimumLevel: .debug,
        categoryFilter: .enabledIncludingSubcategories([OpalDiagnostics.Category.hedge]),
        bufferPolicy: .enabled(capacity: 10_000)
    )

    func withDiagnosticsCapture<Success>(_ operation: () throws -> Success) rethrows -> Success {
        try OpalDiagnostics.withConfiguration(Self.diagnosticsConfiguration) {
            OpalDiagnostics.clearRecentRecords()
            return try operation()
        }
    }

    func findDiagnosticRecord(
        named event: OpalDiagnostics.Event,
        operation: String? = nil
    ) -> OpalDiagnostics.Record? {
        OpalDiagnostics.recentRecords(matching: .init(event: event)).first { record in
            guard let operation else {
                return true
            }
            return findField(OpalDiagnostics.Field.operation, in: record)?.value == operation
        }
    }

    func findField(_ name: String, in record: OpalDiagnostics.Record) -> OpalDiagnostics.Field? {
        record.fields.first { $0.name == name }
    }

    var forbiddenRawDiagnosticFieldNames: Set<String> {
        [
            "address",
            "contract_address",
            "funding_transaction_hash",
            "message_hex",
            "oracle_message",
            "public_key_hex",
            "raw_message",
            "raw_oracle_message",
            "raw_redeem_script_bytecode",
            "raw_settlement_material",
            "redeem_script_bytecode",
            "redeem_script_hex",
            "serialized_payload",
            "settlement_transaction_hash",
            "signature_hex",
            "transaction_hash"
        ]
    }

    func forbiddenRawDiagnosticFieldNames(
        in record: OpalDiagnostics.Record
    ) -> [String] {
        record.fields.map(\.name).filter(forbiddenRawDiagnosticFieldNames.contains)
    }

    func containsForbiddenRawDiagnosticValue(
        in record: OpalDiagnostics.Record,
        forbiddenValues: [String]
    ) -> Bool {
        record.fields.contains { field in
            forbiddenValues.contains { forbiddenValue in
                !forbiddenValue.isEmpty && field.value.contains(forbiddenValue)
            }
        }
    }

    func rawRedeemScriptHexText(
        from bytecode: OpalHedgeBitcoinCashAnyHedgeContractBytecode
    ) -> String {
        bytecode.rawRedeemScriptBytecode.map { String(format: "%02x", $0) }.joined()
    }
}
