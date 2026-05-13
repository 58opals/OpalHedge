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

            return proof
        }

        public static func verifySettlementOracleProof(
            messageHex: String,
            signatureHex: String,
            publicKeyHex: String
        ) throws -> OpalHedge.Core.ContractSettlementOracleProof {
            let message = try OpalHedgeOraclePriceMessage.parse(hex: messageHex)
            let isSignatureValid = try OpalHedgeOracleSignatureVerifier.verify(
                message: message,
                signatureHex: signatureHex,
                publicKeyHex: publicKeyHex
            )
            guard isSignatureValid else {
                throw OpalHedgeSettlementOracleProofError.invalidSignature
            }

            return OpalHedge.Core.ContractSettlementOracleProof(
                message: try OpalHedge.Core.ContractOracleMessageData(
                    hex: message.hex
                ),
                signature: try OpalHedge.Core.ContractOracleSignature(
                    hex: signatureHex
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .lowercased()
                )
            )
        }
    }
}
