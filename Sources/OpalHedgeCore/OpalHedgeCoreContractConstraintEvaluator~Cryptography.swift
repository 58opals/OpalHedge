// OpalHedgeCoreContractConstraintEvaluator~Cryptography.swift

extension OpalHedgeCoreContractConstraintEvaluator {
    static func validateCompressedPublicKeyHex(_ value: String, name: String) throws {
        guard value.count == OpalHedgeCoreContractConstraintPolicy.compressedPublicKeyHexCharacterCount,
              value.allSatisfy({ lowercaseCryptographyHexCharacters.contains($0) }),
              compressedPublicKeyPrefixes.contains(String(value.prefix(2))) else {
            throw OpalHedgeCoreContractConstraintError.invalidPublicKeyHex(
                name: name,
                value: value
            )
        }
    }

    static func validateOracleMessageHex(_ value: String, name: String) throws {
        guard value.count == OpalHedgeCoreContractConstraintPolicy.oraclePriceMessageHexCharacterCount,
              value.allSatisfy({ lowercaseCryptographyHexCharacters.contains($0) }) else {
            throw OpalHedgeCoreContractConstraintError.invalidOracleMessageHex(
                name: name,
                value: value
            )
        }
    }

    static func validateSchnorrSignatureHex(_ value: String, name: String) throws {
        guard value.count == OpalHedgeCoreContractConstraintPolicy.schnorrSignatureHexCharacterCount,
              value.allSatisfy({ lowercaseCryptographyHexCharacters.contains($0) }) else {
            throw OpalHedgeCoreContractConstraintError.invalidOracleSignatureHex(
                name: name,
                value: value
            )
        }
    }

    private static var compressedPublicKeyPrefixes: [String] {
        ["02", "03"]
    }

    private static var lowercaseCryptographyHexCharacters: String {
        "0123456789abcdef"
    }
}
