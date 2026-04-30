// OpalHedgeCoreContractFeeData.swift

public struct OpalHedgeCoreContractFeeData: Sendable, Equatable {
    public let name: String
    public let description: String
    public let address: String
    public let satoshis: Int64

    public init(name: String, description: String, address: String, satoshis: Int64) {
        self.name = name
        self.description = description
        self.address = address
        self.satoshis = satoshis
    }
}
