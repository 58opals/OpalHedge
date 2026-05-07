// OpalHedgeBitcoinCashAnyHedgeContractBytecode.swift

import Foundation

public struct OpalHedgeBitcoinCashAnyHedgeContractBytecode: Sendable, Equatable {
    public let scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
    public let constructorStackPushes: [Data]
    public let constructorStackBytecode: Data
    public let redeemScriptBytecode: Data

    public var artifact: OpalHedgeBitcoinCashContractScriptArtifact {
        scriptBytecode.artifact
    }

    public func deriveContractAddress(
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws -> OpalHedgeBitcoinCashContractAddress {
        try OpalHedgeBitcoinCashContractAddress(
            redeemScript: redeemScriptBytecode,
            network: network
        )
    }

    public init(
        parameters: OpalHedgeBitcoinCashAnyHedgeContractParameterData,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws {
        let constructorStackPushes = try OpalHedgeBitcoinCashAnyHedgeContractParameterEncoder
            .encodeConstructorStackPushes(from: parameters)

        self.init(
            scriptBytecode: scriptBytecode,
            constructorStackPushes: constructorStackPushes
        )
    }

    public init(
        artifact: OpalHedgeBitcoinCashContractScriptArtifact,
        constructorStackPushes: [Data]
    ) {
        self.init(
            scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode(
                artifact: artifact,
                rawHex: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
                    .anyHedgeV0_12.rawHex,
                rawData: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
                    .anyHedgeV0_12.rawData
            ),
            constructorStackPushes: constructorStackPushes
        )
    }

    public init(
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode,
        constructorStackPushes: [Data]
    ) {
        let constructorStackBytecode = constructorStackPushes.reduce(Data()) {
            $0 + $1
        }
        var redeemScriptBytecode = constructorStackBytecode
        redeemScriptBytecode.append(scriptBytecode.rawData)

        self.scriptBytecode = scriptBytecode
        self.constructorStackPushes = constructorStackPushes
        self.constructorStackBytecode = constructorStackBytecode
        self.redeemScriptBytecode = redeemScriptBytecode
    }
}
