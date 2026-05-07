// OpalHedgeBitcoinCashContractAddressError.swift

public enum OpalHedgeBitcoinCashContractAddressError: Error, Sendable, Equatable {
    case invalidRedeemScriptHex(String)
    case invalidScriptHashByteCount(Int)
}
