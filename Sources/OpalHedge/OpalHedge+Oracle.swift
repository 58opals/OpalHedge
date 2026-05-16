// OpalHedge+Oracle.swift

import Foundation
import OpalHedgeCore
import OpalHedgeOracle

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
                let message = try OpalHedgeOraclePriceMessage.parse(hex: messageHex)
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
                        hex: message.hex
                    ),
                    signature: try OpalHedge.Core.ContractOracleSignature(
                        hex: signatureHex
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .lowercased()
                    )
                )
                try OpalHedgeCoreContractConstraintEvaluator.validateStartingOracleProof(proof)

                OpalHedgeDiagnostics.record(
                    OpalHedgeDiagnostics.Event.startingOracleProofVerified,
                    category: OpalHedgeDiagnostics.Category.oracle,
                    fields: [
                        OpalHedgeDiagnostics.operationField("verify_starting_oracle_proof"),
                        OpalHedgeDiagnostics.moduleField("opalhedge"),
                        OpalHedgeDiagnostics.publicField(
                            OpalHedge.Diagnostics.Field.messageTimestamp,
                            message.messageTimestamp
                        ),
                        OpalHedgeDiagnostics.publicField(
                            OpalHedge.Diagnostics.Field.messageSequence,
                            message.messageSequence
                        ),
                        OpalHedgeDiagnostics.publicField(
                            OpalHedge.Diagnostics.Field.priceValue,
                            message.priceValue
                        )
                    ]
                )
                return proof
            } catch {
                OpalHedgeDiagnostics.record(
                    OpalHedgeDiagnostics.Event.startingOracleProofVerificationFailed,
                    category: OpalHedgeDiagnostics.Category.oracle,
                    level: .error,
                    fields: [
                        OpalHedgeDiagnostics.operationField("verify_starting_oracle_proof"),
                        OpalHedgeDiagnostics.moduleField("opalhedge")
                    ] + OpalHedgeDiagnostics.makeErrorFields(for: error)
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
                let message = try OpalHedgeOraclePriceMessage.parse(hex: messageHex)
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
                        hex: message.hex
                    ),
                    signature: try OpalHedge.Core.ContractOracleSignature(
                        hex: signatureHex
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .lowercased()
                    )
                )
                OpalHedgeDiagnostics.record(
                    OpalHedgeDiagnostics.Event.settlementOracleProofVerified,
                    category: OpalHedgeDiagnostics.Category.oracle,
                    fields: [
                        OpalHedgeDiagnostics.operationField("verify_settlement_oracle_proof"),
                        OpalHedgeDiagnostics.moduleField("opalhedge"),
                        OpalHedgeDiagnostics.publicField(
                            OpalHedge.Diagnostics.Field.messageTimestamp,
                            message.messageTimestamp
                        ),
                        OpalHedgeDiagnostics.publicField(
                            OpalHedge.Diagnostics.Field.messageSequence,
                            message.messageSequence
                        ),
                        OpalHedgeDiagnostics.publicField(
                            OpalHedge.Diagnostics.Field.priceValue,
                            message.priceValue
                        )
                    ]
                )
                return proof
            } catch {
                OpalHedgeDiagnostics.record(
                    OpalHedgeDiagnostics.Event.settlementOracleProofVerificationFailed,
                    category: OpalHedgeDiagnostics.Category.oracle,
                    level: .error,
                    fields: [
                        OpalHedgeDiagnostics.operationField("verify_settlement_oracle_proof"),
                        OpalHedgeDiagnostics.moduleField("opalhedge")
                    ] + OpalHedgeDiagnostics.makeErrorFields(for: error)
                )
                throw error
            }
        }
    }
}
