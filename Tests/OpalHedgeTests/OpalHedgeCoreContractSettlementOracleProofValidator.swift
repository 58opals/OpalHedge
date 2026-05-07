// OpalHedgeCoreContractSettlementOracleProofValidator.swift

import Testing
import OpalHedge

struct OpalHedgeCoreContractSettlementOracleProofValidator {
    @Test("Creates contract settlement oracle proof")
    func createContractSettlementOracleProof() throws {
        let proof = try OpalHedge.Core.ContractSettlementOracleProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex
        )

        #expect(proof.message == OpalHedgeFixtureData.contractOracleMessageData)
        #expect(proof.signature == OpalHedgeFixtureData.contractOracleSignature)
        #expect(proof.messageHex == OpalHedgeFixtureData.startingOracleMessageHex)
        #expect(proof.signatureHex == OpalHedgeFixtureData.startingOracleSignatureHex)
        #expect(proof.messageTimestamp == 615_643)
        #expect(proof.messageSequence == 1)
        #expect(proof.priceSequence == 1)
        #expect(proof.priceValue == 23_600)
    }

    @Test("Rejects invalid contract settlement oracle proof")
    func rejectInvalidContractSettlementOracleProof() {
        let messageError = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Core.ContractSettlementOracleProof(
                messageHex: "00",
                signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex
            )
        }
        let signatureError = OpalHedgeTypedErrorCapture.captureConstraintError {
            _ = try OpalHedge.Core.ContractSettlementOracleProof(
                messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
                signatureHex: "00"
            )
        }

        #expect(messageError == .invalidOracleMessageHex(name: "messageHex", value: "00"))
        #expect(signatureError == .invalidOracleSignatureHex(name: "signatureHex", value: "00"))
    }
}
