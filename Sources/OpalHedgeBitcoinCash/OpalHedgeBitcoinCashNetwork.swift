// OpalHedgeBitcoinCashNetwork.swift

public enum OpalHedgeBitcoinCashNetwork: String, Sendable, Equatable {
    case mainnet
    case testnet
    case regtest

    public var cashAddrPrefix: String {
        switch self {
        case .mainnet:
            "bitcoincash"
        case .testnet:
            "bchtest"
        case .regtest:
            "bchreg"
        }
    }
}
