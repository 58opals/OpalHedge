// OpalHedgeBitcoinCashAnyHedgeContractBytecode.swift

import Foundation
import OpalDiagnostics

public struct OpalHedgeBitcoinCashAnyHedgeContractBytecode: Sendable, Equatable {
    public let scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
    public let rawConstructorStackPushes: [Data]
    public let rawConstructorStackBytecode: Data
    public let rawRedeemScriptBytecode: Data

    public var artifact: OpalHedgeBitcoinCashContractScriptArtifact {
        scriptBytecode.artifact
    }

    @available(*, deprecated, renamed: "rawConstructorStackPushes")
    public var constructorStackPushes: [Data] {
        rawConstructorStackPushes
    }

    @available(*, deprecated, renamed: "rawConstructorStackBytecode")
    public var constructorStackBytecode: Data {
        rawConstructorStackBytecode
    }

    @available(*, deprecated, renamed: "rawRedeemScriptBytecode")
    public var redeemScriptBytecode: Data {
        rawRedeemScriptBytecode
    }

    public func deriveContractAddress(
        network: OpalHedgeBitcoinCashNetwork = .mainnet
    ) throws -> OpalHedgeBitcoinCashContractAddress {
        do {
            let address = try OpalHedgeBitcoinCashContractAddress(
                rawRedeemScript: rawRedeemScriptBytecode,
                network: network
            )
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractAddressEncoded,
                level: .debug,
                fields: [
                    OpalDiagnostics.Field.operationField("derive_contract_address"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.byteCount,
                        rawRedeemScriptBytecode.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        "redeem_script"
                    )
                ]
            )
            return address
        } catch {
            OpalDiagnostics.logger(category: OpalDiagnostics.Category.bitcoinCash).record(
                event: OpalDiagnostics.Event.contractAddressEncodingFailed,
                level: .error,
                fields: [
                    OpalDiagnostics.Field.operationField("derive_contract_address"),
                    OpalDiagnostics.Field.moduleField("bitcoin_cash"),
                    OpalDiagnostics.Field.networkField(network),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.byteCount,
                        rawRedeemScriptBytecode.count
                    ),
                    OpalDiagnostics.Field.publicField(
                        OpalDiagnostics.Field.payloadType,
                        "redeem_script"
                    )
                ] + OpalDiagnostics.Field.makeErrorFields(for: error)
            )
            throw error
        }
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
            rawConstructorStackPushes: constructorStackPushes
        )
    }

    public init(
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode,
        rawConstructorStackPushes: [Data]
    ) {
        let constructorStackBytecode = rawConstructorStackPushes.reduce(Data()) {
            $0 + $1
        }
        var redeemScriptBytecode = constructorStackBytecode
        redeemScriptBytecode.append(scriptBytecode.rawScriptData)

        self.scriptBytecode = scriptBytecode
        self.rawConstructorStackPushes = rawConstructorStackPushes
        self.rawConstructorStackBytecode = constructorStackBytecode
        self.rawRedeemScriptBytecode = redeemScriptBytecode
    }

    @available(*, deprecated, message: "Use init(scriptBytecode:rawConstructorStackPushes:) so raw script and constructor stack material are explicit.")
    public init(
        artifact: OpalHedgeBitcoinCashContractScriptArtifact,
        constructorStackPushes: [Data]
    ) {
        self.init(
            scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode(
                artifact: artifact,
                rawScriptHex: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
                    .anyHedgeV0_12.rawScriptHex,
                rawScriptData: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
                    .anyHedgeV0_12.rawScriptData
            ),
            rawConstructorStackPushes: constructorStackPushes
        )
    }

    @available(*, deprecated, message: "Use init(scriptBytecode:rawConstructorStackPushes:) so raw constructor stack material is explicit.")
    public init(
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode,
        constructorStackPushes: [Data]
    ) {
        self.init(
            scriptBytecode: scriptBytecode,
            rawConstructorStackPushes: constructorStackPushes
        )
    }
}
