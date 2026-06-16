// OpalHedge+Oracle.swift

import Foundation
import OpalHedgeCore
import OpalHedgeOracle
import OpalDiagnostics

extension OpalHedge {
    public enum Oracle {
        public typealias Context = OpalHedgeOracleContext
        public typealias MessageError = OpalHedgeOracleMessageError
        public typealias PriceMessage = OpalHedgeOraclePriceMessage
        public typealias StartingPriceProofError = OpalHedgeStartingPriceProofError
        public typealias SettlementOracleProofError = OpalHedgeSettlementOracleProofError
        public typealias SignatureVerificationError = OpalHedgeOracleSignatureVerificationError
        public typealias SignatureVerifier = OpalHedgeOracleSignatureVerifier

        public static func verifyStartingPriceProof(
            messageHex: String,
            signatureHex: String,
            publicKeyHex: String
        ) throws -> OpalHedge.Core.ContractStartingOracleProof {
            do {
                let message = try OpalHedgeOraclePriceMessage.parse(rawHex: messageHex)
                let isSignatureValid = try OpalHedgeOracleSignatureVerifier.verify(
                    message: message,
                    signatureHex: signatureHex,
                    publicKeyHex: publicKeyHex
                )
                guard isSignatureValid else {
                    throw OpalHedgeStartingPriceProofError.invalidSignature
                }

                let proof = OpalHedge.Core.ContractStartingOracleProof(
                    oraclePublicKey: try OpalHedge.Core.ContractPublicKey(
                        hex: publicKeyHex
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .lowercased()
                    ),
                    message: try OpalHedge.Core.ContractOracleMessageData(
                        hex: message.rawMessageHex
                    ),
                    signature: try OpalHedge.Core.ContractOracleSignature(
                        hex: signatureHex
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .lowercased()
                    )
                )
                try OpalHedgeCoreContractConstraintEvaluator.validateStartingOracleProof(proof)

                OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                    event: OpalDiagnostics.Event.startingOracleProofVerified,
                    level: .debug,
                    fields: [
                        OpalDiagnostics.Field.operationField("verify_starting_oracle_proof"),
                        OpalDiagnostics.Field.moduleField("opalhedge"),
                        OpalDiagnostics.Field.publicField(
                            OpalDiagnostics.Field.messageTimestamp,
                            message.messageTimestamp
                        ),
                        OpalDiagnostics.Field.publicField(
                            OpalDiagnostics.Field.messageSequence,
                            message.messageSequence
                        ),
                        OpalDiagnostics.Field.publicField(
                            OpalDiagnostics.Field.priceValue,
                            message.priceValue
                        )
                    ]
                )
                return proof
            } catch {
                OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                    event: OpalDiagnostics.Event.startingOracleProofVerificationFailed,
                    level: .error,
                    fields: [
                        OpalDiagnostics.Field.operationField("verify_starting_oracle_proof"),
                        OpalDiagnostics.Field.moduleField("opalhedge")
                    ] + OpalDiagnostics.Field.makeErrorFields(for: error)
                )
                throw error
            }
        }

        public static func verifySettlementOracleProof(
            messageHex: String,
            signatureHex: String,
            publicKeyHex: String
        ) throws -> OpalHedge.Core.ContractSettlementOracleProof {
            do {
                let message = try OpalHedgeOraclePriceMessage.parse(rawHex: messageHex)
                let isSignatureValid = try OpalHedgeOracleSignatureVerifier.verify(
                    message: message,
                    signatureHex: signatureHex,
                    publicKeyHex: publicKeyHex
                )
                guard isSignatureValid else {
                    throw OpalHedgeSettlementOracleProofError.invalidSignature
                }

                let proof = OpalHedge.Core.ContractSettlementOracleProof(
                    message: try OpalHedge.Core.ContractOracleMessageData(
                        hex: message.rawMessageHex
                    ),
                    signature: try OpalHedge.Core.ContractOracleSignature(
                        hex: signatureHex
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .lowercased()
                    )
                )
                OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                    event: OpalDiagnostics.Event.settlementOracleProofVerified,
                    level: .debug,
                    fields: [
                        OpalDiagnostics.Field.operationField("verify_settlement_oracle_proof"),
                        OpalDiagnostics.Field.moduleField("opalhedge"),
                        OpalDiagnostics.Field.publicField(
                            OpalDiagnostics.Field.messageTimestamp,
                            message.messageTimestamp
                        ),
                        OpalDiagnostics.Field.publicField(
                            OpalDiagnostics.Field.messageSequence,
                            message.messageSequence
                        ),
                        OpalDiagnostics.Field.publicField(
                            OpalDiagnostics.Field.priceValue,
                            message.priceValue
                        )
                    ]
                )
                return proof
            } catch {
                OpalDiagnostics.logger(category: OpalDiagnostics.Category.oracle).record(
                    event: OpalDiagnostics.Event.settlementOracleProofVerificationFailed,
                    level: .error,
                    fields: [
                        OpalDiagnostics.Field.operationField("verify_settlement_oracle_proof"),
                        OpalDiagnostics.Field.moduleField("opalhedge")
                    ] + OpalDiagnostics.Field.makeErrorFields(for: error)
                )
                throw error
            }
        }
    }
}
