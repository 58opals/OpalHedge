// OpalHedgeBitcoinCashTransactionHashValidator.swift

enum OpalHedgeBitcoinCashTransactionHashValidator {
    static func isValid(_ value: String) -> Bool {
        value.utf8.count == transactionHashHexCharacterCount
            && value.allSatisfy(hexCharacters.contains)
    }

    private static let transactionHashHexCharacterCount = 64

    private static var hexCharacters: String {
        "0123456789abcdefABCDEF"
    }
}
