// OpalDiagnosticsIntegrationValidator+Support.swift

import OpalDiagnostics

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
}
