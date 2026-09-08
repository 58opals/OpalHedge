// OpalDiagnosticsIntegrationValidator+Trace.swift

import OpalDiagnostics
import OpalHedge
import Testing

extension OpalDiagnosticsIntegrationValidator {
    @Test("Diagnostics extensions expose stable filter values")
    func verifyDiagnosticsExtensionsExposeStableFilterValues() {
        let categories: [OpalDiagnostics.Category] = [
            OpalDiagnostics.Category.hedge,
            OpalDiagnostics.Category.contract,
            OpalDiagnostics.Category.dataDocument,
            OpalDiagnostics.Category.oracle,
            OpalDiagnostics.Category.bitcoinCash,
            OpalDiagnostics.Category.funding,
            OpalDiagnostics.Category.settlement
        ]

        #expect(categories.map(\.rawValue) == [
            "hedge",
            "hedge.contract",
            "hedge.data_document",
            "hedge.oracle",
            "hedge.bitcoin_cash",
            "hedge.funding",
            "hedge.settlement"
        ])
        #expect(OpalDiagnostics.Event.contractPlanCreated.rawValue == "opalhedge.contract.plan.created")
        #expect(OpalDiagnostics.Event.transactionHashValidationFailed.rawValue == "opalhedge.bitcoin_cash.transaction_hash.validation_failed")
        #expect(OpalDiagnostics.Field.errorCode == "error_code")
        #expect(OpalDiagnostics.TraceID(publicValue: "wallet-action").rawValue == "wallet-action")
        #expect(OpalDiagnostics.currentTraceID == nil)
    }

    @Test("Wallet action diagnostics share trace ID")
    func verifyWalletActionDiagnosticsShareTraceID() throws {
        try withDiagnosticsCapture {
            let traceID = OpalDiagnostics.TraceID(publicValue: "wallet-action-123")
            let clientContext = OpalHedge.Client.Context()
            let fundingTransactionHash = String(repeating: "1", count: 64)
            let settlementTransactionHash = String(repeating: "2", count: 64)

            try OpalDiagnostics.withTraceID(traceID) {
                #expect(OpalDiagnostics.currentTraceID == traceID)

                let plan = try OpalHedge.Core.ContractPlan(
                    from: OpalHedgeFixtureData.contractCreationContext
                )
                _ = try clientContext.createAnyHedgeContractFundingRequest(
                    from: plan
                )
                _ = try clientContext.createAnyHedgeContractSettlementSummary(
                    from: plan,
                    fundingTransactionHash: fundingTransactionHash,
                    fundingOutputIndex: 0,
                    previousOracleProof: OpalHedgeContractFixtureBuilder
                        .makeStartingSettlementOracleProof(),
                    settlementOracleProof: OpalHedgeContractFixtureBuilder
                        .makeSettlementOracleProof(),
                    settlementTransactionHash: settlementTransactionHash
                )
            }

            #expect(OpalDiagnostics.currentTraceID == nil)
            let traceRecords = OpalDiagnostics.recentRecords(matching: .init(traceID: traceID))
                .filter { $0.category.isOpalHedgeCategory }
            let traceEvents = Set(traceRecords.map(\.event))
            #expect(traceRecords.isEmpty == false)
            #expect(traceEvents.contains(OpalDiagnostics.Event.contractPlanCreated))
            #expect(traceEvents.contains(OpalDiagnostics.Event.fundingRequestCreated))
            #expect(traceEvents.contains(OpalDiagnostics.Event.fundingRecordCreated))
            #expect(traceEvents.contains(OpalDiagnostics.Event.settlementRequestCreated))
            #expect(traceEvents.contains(OpalDiagnostics.Event.settlementRecordCreated))
            #expect(traceEvents.contains(OpalDiagnostics.Event.settlementSummaryCreated))
            #expect(OpalDiagnostics.recentRecords.allSatisfy { $0.traceID == traceID })
        }
    }

    @Test("Nested trace scopes preserve current trace ID")
    func verifyNestedTraceScopesPreserveCurrentTraceID() throws {
        try withDiagnosticsCapture {
            let traceID = OpalDiagnostics.TraceID(publicValue: "wallet-action-nested")

            try OpalDiagnostics.withTraceID(traceID) {
                try OpalDiagnostics.withTraceID(traceID) {
                    _ = try OpalHedge.Core.ContractPlan(
                        from: OpalHedgeFixtureData.contractCreationContext
                    )
                }
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.contractPlanCreated)
            )
            #expect(record.traceID == traceID)
        }
    }

    @Test("Generated root trace ID is visible inside scope")
    func verifyGeneratedRootTraceIDIsVisibleInsideScope() throws {
        try withDiagnosticsCapture {
            let traceID = OpalDiagnostics.TraceID()
            try OpalDiagnostics.withTraceID(traceID) {
                #expect(OpalDiagnostics.currentTraceID == traceID)
                _ = try OpalHedge.Core.ContractPlan(
                    from: OpalHedgeFixtureData.contractCreationContext
                )
            }

            let record = try #require(
                findDiagnosticRecord(named: OpalDiagnostics.Event.contractPlanCreated)
            )
            #expect(traceID.rawValue.isEmpty == false)
            #expect(record.traceID == traceID)
        }
    }

    @Test("Direct trace record query can filter to OpalHedge categories")
    func verifyDirectTraceRecordQueryCanFilterToOpalHedgeCategories() throws {
        try OpalDiagnostics.withConfiguration(
            .init(minimumLevel: .debug, bufferPolicy: .enabled(capacity: 10_000))
        ) {
            OpalDiagnostics.clearRecentRecords()
            let traceID = OpalDiagnostics.TraceID(publicValue: "wallet-action-mixed")

            try OpalDiagnostics.withTraceID(traceID) {
                _ = try OpalHedge.Core.ContractPlan(
                    from: OpalHedgeFixtureData.contractCreationContext
                )
                OpalDiagnostics.logger(category: .fulcrum).record(
                    event: "fulcrum.connected",
                    level: .debug
                )
            }

            #expect(
                OpalDiagnostics.recentRecords(matching: .init(traceID: traceID))
                    .contains { $0.category == .fulcrum }
            )
            let hedgeRecords = OpalDiagnostics.recentRecords(matching: .init(traceID: traceID))
                .filter { $0.category.isOpalHedgeCategory }
            #expect(hedgeRecords.isEmpty == false)
            #expect(hedgeRecords.map(\.event).contains(
                OpalDiagnostics.Event.contractPlanCreated
            ))
        }
    }

    @Test("Category filters support exact and hierarchical OpalHedge matching")
    func verifyCategoryFiltersSupportExactAndHierarchicalOpalHedgeMatching() {
        OpalDiagnostics.withConfiguration(
            .init(
                minimumLevel: .debug,
                categoryFilter: .enabled([OpalDiagnostics.Category.hedge]),
                bufferPolicy: .enabled(capacity: 10)
            )
        ) {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.hedge).record(
                event: "opalhedge.root",
                level: .debug
            )
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractPlanCreated,
                level: .debug
            )

            #expect(OpalDiagnostics.recentRecords.map(\.category) == [OpalDiagnostics.Category.hedge])
        }

        OpalDiagnostics.withConfiguration(
            .init(
                minimumLevel: .debug,
                categoryFilter: .enabledIncludingSubcategories([OpalDiagnostics.Category.hedge]),
                bufferPolicy: .enabled(capacity: 10)
            )
        ) {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractPlanCreated,
                level: .debug
            )
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                event: OpalDiagnostics.Event.oracleMessageParsed,
                level: .debug
            )
            OpalDiagnostics.logger(category: .fulcrum).record(
                event: "fulcrum.filtered",
                level: .debug
            )

            #expect(OpalDiagnostics.recentRecords.map(\.category) == [
                OpalDiagnostics.Category.contract,
                OpalDiagnostics.Category.oracle
            ])
        }
    }
}
