// OpalHedgeOracleStartingPriceProofValidator.swift

import Testing
import OpalHedge

enum StartingPriceProofNormalizationCase: CaseIterable, CustomStringConvertible, Sendable {
    case uppercaseHex
    case surroundingWhitespace

    var description: String {
        switch self {
        case .uppercaseHex:
            "uppercase hex"
        case .surroundingWhitespace:
            "surrounding whitespace"
        }
    }
}

struct OpalHedgeOracleStartingPriceProofValidator {
    @Test("Verifies upstream starting price proof")
    func verifyUpstreamStartingPriceProof() throws {
        let proof = try OpalHedge.Oracle.verifyStartingPriceProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )

        #expect(proof == OpalHedgeFixtureData.contractStartingOracleProof)
    }

    @Test(
        "Normalizes verified starting price proof input",
        arguments: StartingPriceProofNormalizationCase.allCases
    )
    func normalizeVerifiedStartingPriceProofInput(
        _ normalizationCase: StartingPriceProofNormalizationCase
    ) throws {
        let proof = try OpalHedge.Oracle.verifyStartingPriceProof(
            messageHex: messageHex(for: normalizationCase),
            signatureHex: signatureHex(for: normalizationCase),
            publicKeyHex: publicKeyHex(for: normalizationCase)
        )

        #expect(proof == OpalHedgeFixtureData.contractStartingOracleProof)
    }

    @Test("Rejects invalid starting price signature")
    func rejectInvalidStartingPriceSignature() {
        let error = OpalHedgeTypedErrorCaptureTool.captureStartingPriceProofError {
            _ = try OpalHedge.Oracle.verifyStartingPriceProof(
                messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
                signatureHex: invalidSignatureHex,
                publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
            )
        }

        #expect(error == .invalidSignature)
    }

    private var invalidSignatureHex: String {
        let finalCharacter = OpalHedgeFixtureData.startingOracleSignatureHex.hasSuffix("0") ? "1" : "0"

        return String(OpalHedgeFixtureData.startingOracleSignatureHex.dropLast()) + finalCharacter
    }

    private func messageHex(for normalizationCase: StartingPriceProofNormalizationCase) -> String {
        switch normalizationCase {
        case .uppercaseHex:
            OpalHedgeFixtureData.startingOracleMessageHex.uppercased()
        case .surroundingWhitespace:
            OpalHedgeFixtureData.startingOracleMessageHex
        }
    }

    private func signatureHex(for normalizationCase: StartingPriceProofNormalizationCase) -> String {
        switch normalizationCase {
        case .uppercaseHex:
            OpalHedgeFixtureData.startingOracleSignatureHex.uppercased()
        case .surroundingWhitespace:
            " \(OpalHedgeFixtureData.startingOracleSignatureHex.uppercased())\n"
        }
    }

    private func publicKeyHex(for normalizationCase: StartingPriceProofNormalizationCase) -> String {
        switch normalizationCase {
        case .uppercaseHex:
            OpalHedgeFixtureData.oraclePublicKeyHex.uppercased()
        case .surroundingWhitespace:
            "\n\(OpalHedgeFixtureData.oraclePublicKeyHex.uppercased()) "
        }
    }
}
