// OpalHedgeOracleMessageError.swift

public enum OpalHedgeOracleMessageError: Error, Sendable, Equatable {
    case invalidHexLength(actual: Int)
    case invalidHexCharacter(String)
    case invalidMessageLength(expected: Int, actual: Int)
    case invalidScriptInteger(name: String, value: Int64)
    case invalidPrice(Int64)
}
