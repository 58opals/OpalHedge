// OpalHedge+Diagnostics.swift

public import OpalDiagnostics

extension OpalHedge {
    public enum Diagnostics {
        /// Public-safe correlation identifier for following one Wallet action across records.
        public typealias TraceID = OpalDiagnostics.TraceID

        /// Trace ID currently scoped to this task, if one has been installed.
        public static var currentTraceID: TraceID? {
            OpalDiagnostics.currentTraceID
        }

        /// Returns recent OpalHedge records associated with a trace ID.
        public static func recentRecords(
            traceID: TraceID
        ) -> [OpalDiagnostics.Record] {
            OpalDiagnostics.recentRecords.filter { record in
                record.traceID == traceID && isHedgeCategory(record.category)
            }
        }

        /// Runs an operation with a trace ID scoped to the current task and inherited child tasks.
        public static func withTraceID<Success>(
            _ traceID: TraceID,
            operation: () throws -> Success
        ) rethrows -> Success {
            try OpalDiagnostics.withTraceID(traceID, operation: operation)
        }

        /// Runs an operation with the current trace ID, or starts a new root trace when none exists.
        public static func withTraceID<Success>(
            operation: () throws -> Success
        ) rethrows -> Success {
            try withTraceID(resolveTraceID(), operation: operation)
        }

        /// Runs an operation with a new root trace ID and passes the ID to the operation.
        public static func withNewTraceID<Success>(
            operation: (TraceID) throws -> Success
        ) rethrows -> Success {
            let traceID = TraceID()
            return try withTraceID(traceID) {
                try operation(traceID)
            }
        }

        /// Runs an async operation with a trace ID scoped to the current task and inherited child tasks.
        public static func withTraceID<Success>(
            _ traceID: TraceID,
            operation: () async throws -> Success
        ) async rethrows -> Success {
            try await OpalDiagnostics.withTraceID(traceID, operation: operation)
        }

        /// Runs an async operation with the current trace ID, or starts a new root trace when none exists.
        public static func withTraceID<Success>(
            operation: () async throws -> Success
        ) async rethrows -> Success {
            try await withTraceID(resolveTraceID(), operation: operation)
        }

        /// Runs an async operation with a new root trace ID and passes the ID to the operation.
        public static func withNewTraceID<Success>(
            operation: (TraceID) async throws -> Success
        ) async rethrows -> Success {
            let traceID = TraceID()
            return try await withTraceID(traceID) {
                try await operation(traceID)
            }
        }

        /// Stable diagnostics categories that callers may use with OpalDiagnostics filters.
        public enum Category {
            public static let hedge: OpalDiagnostics.Category = .hedge
            public static let contract = OpalDiagnostics.Category(rawValue: "hedge.contract")
            public static let dataDocument = OpalDiagnostics.Category(rawValue: "hedge.data_document")
            public static let oracle = OpalDiagnostics.Category(rawValue: "hedge.oracle")
            public static let bitcoinCash = OpalDiagnostics.Category(rawValue: "hedge.bitcoin_cash")
            public static let funding = OpalDiagnostics.Category(rawValue: "hedge.funding")
            public static let settlement = OpalDiagnostics.Category(rawValue: "hedge.settlement")
        }

        /// Stable diagnostics events that callers may use with OpalDiagnostics filters.
        public enum Event {
            public static let contractPlanCreated = OpalDiagnostics.Event(rawValue: "opalhedge.contract.plan.created")
            public static let contractPlanCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.contract.plan.creation_failed")
            public static let contractConstraintsValidated = OpalDiagnostics.Event(rawValue: "opalhedge.contract.constraints.validated")
            public static let contractConstraintValidationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.contract.constraints.validation_failed")

            public static let dataDocumentEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.encoded")
            public static let dataDocumentEncodeFailed = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.encode_failed")
            public static let dataDocumentDecoded = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.decoded")
            public static let dataDocumentDecodeFailed = OpalDiagnostics.Event(rawValue: "opalhedge.data_document.decode_failed")

            public static let oracleMessageParsed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.message.parsed")
            public static let oracleMessageParseFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.message.parse_failed")
            public static let oracleSignatureVerified = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.signature.verified")
            public static let oracleSignatureVerificationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.signature.verification_failed")
            public static let startingOracleProofVerified = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.starting_proof.verified")
            public static let startingOracleProofVerificationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.starting_proof.verification_failed")
            public static let settlementOracleProofVerified = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.settlement_proof.verified")
            public static let settlementOracleProofVerificationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.oracle.settlement_proof.verification_failed")

            public static let contractAddressEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_address.encoded")
            public static let contractAddressEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_address.encoding_failed")
            public static let contractParametersEncoded = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_parameters.encoded")
            public static let contractParameterEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_parameters.encoding_failed")
            public static let contractScriptEncodingFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.contract_script.encoding_failed")
            public static let transactionHashValidationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.bitcoin_cash.transaction_hash.validation_failed")

            public static let fundingRequestCreated = OpalDiagnostics.Event(rawValue: "opalhedge.funding.request.created")
            public static let fundingRequestCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.funding.request.creation_failed")
            public static let fundingRecordCreated = OpalDiagnostics.Event(rawValue: "opalhedge.funding.record.created")
            public static let fundingRecordCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.funding.record.creation_failed")

            public static let settlementConditionResolved = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.condition.resolved")
            public static let settlementConditionResolutionFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.condition.resolution_failed")
            public static let settlementPayoutCalculated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.payout.calculated")
            public static let settlementPayoutCalculationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.payout.calculation_failed")
            public static let settlementRequestCreated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.request.created")
            public static let settlementRequestCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.request.creation_failed")
            public static let settlementRecordCreated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.record.created")
            public static let settlementRecordCreationFailed = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.record.creation_failed")
            public static let settlementSummaryCreated = OpalDiagnostics.Event(rawValue: "opalhedge.settlement.summary.created")
        }

        /// Stable public diagnostics field names.
        public enum Field {
            public static let operation = "operation"
            public static let module = "module"
            public static let network = "network"
            public static let settlementKind = "settlement_kind"
            public static let constraintCategory = "constraint_category"
            public static let errorCategory = "error_category"
            public static let errorCode = "error_code"
            public static let errorMessage = "error_message"
            public static let fundingCount = "funding_count"
            public static let feeCount = "fee_count"
            public static let fundingIndex = "funding_index"
            public static let byteCount = "byte_count"
            public static let pushCount = "push_count"
            public static let payloadType = "payload_type"
            public static let outputIndex = "output_index"
            public static let satoshiCount = "satoshi_count"
            public static let settlementPrice = "settlement_price"
            public static let messageTimestamp = "message_timestamp"
            public static let messageSequence = "message_sequence"
            public static let priceSequence = "price_sequence"
            public static let priceValue = "price_value"
        }

        /// Stable public diagnostics error codes for common OpalHedge failure classes.
        public enum ErrorCode {
            public static let unknown = "unknown"
            public static let contractPlanCreationFailed = "contract.plan_creation_failed"
            public static let contractConstraintValidationFailed = "contract.constraint_validation_failed"
            public static let dataDocumentInvalidJson = "data_document.invalid_json"
            public static let dataDocumentInvalidRootObject = "data_document.invalid_root_object"
            public static let dataDocumentMissingField = "data_document.missing_field"
            public static let dataDocumentInvalidFieldType = "data_document.invalid_field_type"
            public static let dataDocumentInvalidContractSide = "data_document.invalid_contract_side"
            public static let dataDocumentInvalidSettlementType = "data_document.invalid_settlement_type"
            public static let dataDocumentEncodeFailed = "data_document.encode_failed"
            public static let dataDocumentDecodeFailed = "data_document.decode_failed"
            public static let oracleInvalidHexLength = "oracle.invalid_hex_length"
            public static let oracleInvalidHexCharacter = "oracle.invalid_hex_character"
            public static let oracleInvalidMessageLength = "oracle.invalid_message_length"
            public static let oracleInvalidScriptInteger = "oracle.invalid_script_integer"
            public static let oracleInvalidPrice = "oracle.invalid_price"
            public static let oracleInvalidPublicKey = "oracle.invalid_public_key"
            public static let oracleInvalidSignature = "oracle.invalid_signature"
            public static let oracleInvalidDigest = "oracle.invalid_digest"
            public static let oracleCryptographyFailure = "oracle.cryptography_failure"
            public static let bitcoinCashInvalidRedeemScriptHex = "bitcoin_cash.invalid_redeem_script_hex"
            public static let bitcoinCashInvalidScriptHashByteCount = "bitcoin_cash.invalid_script_hash_byte_count"
            public static let bitcoinCashScriptDataPushTooLarge = "bitcoin_cash.script.data_push_too_large"
            public static let bitcoinCashParameterInvalidHex = "bitcoin_cash.parameter.invalid_hex"
            public static let bitcoinCashParameterInvalidCompressedPublicKey = "bitcoin_cash.parameter.invalid_compressed_public_key"
            public static let bitcoinCashParameterInvalidLockScript = "bitcoin_cash.parameter.invalid_lock_script"
            public static let bitcoinCashParameterInvalidPositiveInteger = "bitcoin_cash.parameter.invalid_positive_integer"
            public static let bitcoinCashParameterInvalidNonnegativeInteger = "bitcoin_cash.parameter.invalid_nonnegative_integer"
            public static let bitcoinCashParameterInvalidBooleanInteger = "bitcoin_cash.parameter.invalid_boolean_integer"
            public static let transactionHashInvalid = "bitcoin_cash.transaction_hash.invalid"
            public static let fundingAlreadyExists = "funding.already_exists"
            public static let fundingRecordInvalid = "funding.record_invalid"
            public static let settlementConditionInvalid = "settlement.condition_invalid"
            public static let settlementPayoutInvalid = "settlement.payout_invalid"
            public static let settlementRecordInvalid = "settlement.record_invalid"
        }

        private static func isHedgeCategory(_ category: OpalDiagnostics.Category) -> Bool {
            category == Category.hedge
                || category.rawValue.hasPrefix("\(Category.hedge.rawValue).")
        }

        private static func resolveTraceID() -> TraceID {
            currentTraceID ?? TraceID()
        }
    }
}
