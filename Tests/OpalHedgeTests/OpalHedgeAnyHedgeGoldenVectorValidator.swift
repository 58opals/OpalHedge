// OpalHedgeAnyHedgeGoldenVectorValidator.swift

import Foundation
import Testing
import OpalHedge

struct OpalHedgeAnyHedgeGoldenVectorValidator {
    @Test("Matches upstream hedge ten week AnyHedge golden vector")
    func matchUpstreamHedgeTenWeekAnyHedgeGoldenVector() throws {
        let startingProof = try OpalHedge.Oracle.verifyStartingPriceProof(
            messageHex: OpalHedgeFixtureData.startingOracleMessageHex,
            signatureHex: OpalHedgeFixtureData.startingOracleSignatureHex,
            publicKeyHex: OpalHedgeFixtureData.oraclePublicKeyHex
        )
        let plan = try OpalHedge.Core.ContractPlanner.createPlan(
            from: OpalHedgeFixtureData.contractCreationContext
        )
        let parameterData = try OpalHedge.BitcoinCash.AnyHedgeContractParameterData(
            from: plan
        )
        let constructorStackPushHexTexts = try OpalHedge.BitcoinCash
            .AnyHedgeContractParameterEncoder
            .encodeConstructorStackPushes(from: parameterData)
            .map(hexText)
        let bytecode = try OpalHedge.BitcoinCash.AnyHedgeContractBytecode(
            parameters: parameterData
        )
        let address = try bytecode.deriveContractAddress(network: .mainnet)
        let bundle = try OpalHedge.BitcoinCash.AnyHedgeContractBundle(
            plan: plan
        )

        #expect(startingProof == OpalHedgeFixtureData.contractStartingOracleProof)
        #expect(plan.parameters == OpalHedgeFixtureData.contractParameters)
        #expect(constructorStackPushHexTexts == OpalHedgeAnyHedgeGoldenVectorData
            .constructorStackPushHexTexts)
        #expect(hexText(bytecode.constructorStackBytecode) == OpalHedgeAnyHedgeGoldenVectorData
            .constructorStackBytecodeHex)
        #expect(bytecode.constructorStackPushes.count == OpalHedgeAnyHedgeGoldenVectorData
            .constructorStackPushCount)
        #expect(bytecode.constructorStackBytecode.count == OpalHedgeAnyHedgeGoldenVectorData
            .constructorStackBytecodeByteCount)
        #expect(bytecode.redeemScriptBytecode.count == OpalHedgeAnyHedgeGoldenVectorData
            .redeemScriptBytecodeByteCount)
        #expect(hexText(bytecode.redeemScriptBytecode).hasSuffix(
            OpalHedgeAnyHedgeGoldenVectorData.contractScriptBytecodeSuffixHex
        ))
        #expect(hexText(address.scriptHash) == OpalHedgeAnyHedgeGoldenVectorData
            .mainnetContractScriptHashHex)
        #expect(address.rawValue == OpalHedgeAnyHedgeGoldenVectorData.mainnetContractAddress)
        #expect(bundle.contractAddress == address)
        #expect(bundle.fundingOutput.payoutSatoshis == OpalHedgeAnyHedgeGoldenVectorData
            .payoutSatoshis)
        #expect(bundle.fundingOutput.dustReserveSatoshis == OpalHedgeAnyHedgeGoldenVectorData
            .dustReserveSatoshis)
        #expect(bundle.fundingOutput.satoshis == OpalHedgeAnyHedgeGoldenVectorData
            .fundingOutputSatoshis)
        #expect(bundle.dataDocument.jsonText == OpalHedgeAnyHedgeGoldenVectorData
            .contractDataDocumentJsonText)
        #expect(bundle.fundingRequest.contractDataDocument == bundle.dataDocument)
        #expect(bundle.fundingRequest.redeemScriptBytecode == bytecode.redeemScriptBytecode)
        #expect(bundle.fundingRequest.contractScriptArtifact == .anyHedgeV0_12)
    }

    @Test("Keeps official AnyHedge and PriceOracle source references with vector")
    func keepOfficialAnyHedgeAndPriceOracleSourceReferencesWithVector() {
        #expect(OpalHedgeAnyHedgeGoldenVectorData.sourceUrls.contains(
            OpalHedgeFixtureReferenceData.anyHedgeContractMetadataV1Url
        ))
        #expect(OpalHedgeAnyHedgeGoldenVectorData.sourceUrls.contains(
            OpalHedgeFixtureReferenceData.anyHedgeContractFundingV1Url
        ))
        #expect(OpalHedgeAnyHedgeGoldenVectorData.sourceUrls.contains(
            OpalHedgeFixtureReferenceData.anyHedgeContractAutomatedPayoutV1Url
        ))
        #expect(OpalHedgeAnyHedgeGoldenVectorData.sourceUrls.contains(
            OpalHedgeFixtureReferenceData.priceOracleLibraryUrl
        ))
    }

    @Test("Documents golden vector source reference coverage")
    func documentGoldenVectorSourceReferenceCoverage() {
        for reference in OpalHedgeAnyHedgeGoldenVectorData.sourceReferences {
            #expect(!reference.title.isEmpty)
            #expect(!reference.url.isEmpty)
            #expect(reference.url.hasPrefix("https://"))
            #expect(!reference.coveredFixtureNames.isEmpty)
        }

        let fixtureNames = Set(OpalHedgeAnyHedgeGoldenVectorData.sourceReferences
            .flatMap(\.coveredFixtureNames))
        let expectedFixtureNames: Set<String> = [
            OpalHedgeAnyHedgeGoldenVectorData.upstreamHedgeTenWeekContractMetadataFixtureName,
            OpalHedgeAnyHedgeGoldenVectorData.upstreamHedgeTenWeekContractFundingsFixtureName,
            OpalHedgeAnyHedgeGoldenVectorData.upstreamHedgeTenWeekContractSettlementFixtureName,
            "oraclePublicKeyHex",
            "startingOracleMessageHex",
            "startingOracleSignatureHex"
        ]
        #expect(fixtureNames.isSuperset(of: expectedFixtureNames))
    }

    @Test("Groups golden vector source references by interface family")
    func groupGoldenVectorSourceReferencesByInterfaceFamily() {
        let sourceReferencesByFamily = Dictionary(
            grouping: OpalHedgeAnyHedgeGoldenVectorData.sourceReferences,
            by: \.family
        )
        let expectedSourceFamilies: Set<OpalHedgeFixtureSourceFamily> = [
            .anyHedgeContractMetadata,
            .anyHedgeContractFunding,
            .anyHedgeContractAutomatedPayout,
            .priceOracle
        ]

        #expect(Set(sourceReferencesByFamily.keys) == expectedSourceFamilies)
        #expect(sourceReferencesByFamily[.anyHedgeContractMetadata]?
            .flatMap(\.coveredFixtureNames) == [
                OpalHedgeAnyHedgeGoldenVectorData.upstreamHedgeTenWeekContractMetadataFixtureName
            ])
        #expect(sourceReferencesByFamily[.anyHedgeContractFunding]?
            .flatMap(\.coveredFixtureNames) == [
                OpalHedgeAnyHedgeGoldenVectorData.upstreamHedgeTenWeekContractFundingsFixtureName
            ])
        #expect(sourceReferencesByFamily[.anyHedgeContractAutomatedPayout]?
            .flatMap(\.coveredFixtureNames) == [
                OpalHedgeAnyHedgeGoldenVectorData.upstreamHedgeTenWeekContractSettlementFixtureName
            ])
        #expect(sourceReferencesByFamily[.priceOracle]?.flatMap(\.coveredFixtureNames) == [
            "oraclePublicKeyHex",
            "startingOracleMessageHex",
            "startingOracleSignatureHex"
        ])
    }

    private func hexText(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}
