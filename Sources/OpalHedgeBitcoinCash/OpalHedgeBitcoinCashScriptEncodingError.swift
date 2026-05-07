// OpalHedgeBitcoinCashScriptEncodingError.swift

public enum OpalHedgeBitcoinCashScriptEncodingError: Error, Sendable, Equatable {
    case dataPushTooLarge(Int)
}
