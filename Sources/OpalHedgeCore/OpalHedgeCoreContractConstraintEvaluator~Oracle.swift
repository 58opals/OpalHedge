// OpalHedgeCoreContractConstraintEvaluator~Oracle.swift

import OpalDiagnostics

extension OpalHedgeCoreContractConstraintEvaluator {
    public static func validateStartingOracleProof(
        _ proof: OpalHedgeCoreContractStartingOracleProof
    ) throws {
        do {
            try validateCompressedPublicKeyHex(proof.oraclePublicKeyHex, name: "oraclePublicKeyHex")
            try validateOracleMessageData(proof.message)
            try validateSchnorrSignatureHex(proof.signatureHex, name: "signatureHex")
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintsValidated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_starting_oracle_proof"),
                    OpalDiagnostics.Field.moduleField("core")
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintValidationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_starting_oracle_proof"),
                    OpalDiagnostics.Field.moduleField("core")
                ] + OpalDiagnostics.Field.makeConstraintFields(for: error)
                    + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }

    public static func validateOracleMessageData(
        _ message: OpalHedgeCoreContractOracleMessageData
    ) throws {
        do {
            try validateOracleMessageHex(message.hex, name: "messageHex")
            try validateFourBytePositiveScriptInteger(message.messageTimestamp, name: "messageTimestamp")
            try validateFourBytePositiveScriptInteger(message.messageSequence, name: "messageSequence")
            try validateFourBytePositiveScriptInteger(message.priceSequence, name: "priceSequence")
            try validateFourBytePositiveScriptInteger(message.priceValue, name: "priceValue")
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintsValidated,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_oracle_message_data"),
                    OpalDiagnostics.Field.moduleField("core")
                ]
            )
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.contract).record(
                event: OpalDiagnostics.Event.contractConstraintValidationFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("validate_oracle_message_data"),
                    OpalDiagnostics.Field.moduleField("core")
                ] + OpalDiagnostics.Field.makeConstraintFields(for: error)
                    + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
    }
}
