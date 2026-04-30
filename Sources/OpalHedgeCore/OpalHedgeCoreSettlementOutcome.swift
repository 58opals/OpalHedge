// OpalHedgeCoreSettlementOutcome.swift

public struct OpalHedgeCoreSettlementOutcome: Sendable, Equatable {
    public let clampedPrice: Int64
    public let shortPayoutSatsSafe: Int64
    public let longPayoutSatsSafe: Int64
    public let totalPayoutSatsSafe: Int64
    public let satsForNominalUnits: Int64
    public let minerFeeSats: Int64

    public init(
        clampedPrice: Int64,
        shortPayoutSatsSafe: Int64,
        longPayoutSatsSafe: Int64,
        totalPayoutSatsSafe: Int64,
        satsForNominalUnits: Int64,
        minerFeeSats: Int64
    ) {
        self.clampedPrice = clampedPrice
        self.shortPayoutSatsSafe = shortPayoutSatsSafe
        self.longPayoutSatsSafe = longPayoutSatsSafe
        self.totalPayoutSatsSafe = totalPayoutSatsSafe
        self.satsForNominalUnits = satsForNominalUnits
        self.minerFeeSats = minerFeeSats
    }
}
