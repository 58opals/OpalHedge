// OpalHedge+Oracle.swift

import OpalHedgeCore
import OpalHedgeOracle

extension OpalHedge {
    public enum Oracle {
        public typealias Context = OpalHedgeOracleContext
        public typealias MessageError = OpalHedgeOracleMessageError
        public typealias PriceMessage = OpalHedgeOraclePriceMessage
        public typealias StartingPriceProofError = OpalHedgeStartingPriceProofError
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
                    hex: publicKeyHex.lowercased()
                ),
                message: try OpalHedge.Core.ContractOracleMessageData(
                    hex: message.hex
                ),
                signature: try OpalHedge.Core.ContractOracleSignature(
                    hex: signatureHex.lowercased()
                )
            )
            try OpalHedgeCoreContractConstraintEvaluator.validateStartingOracleProof(proof)

            return proof
        }
    }
}
