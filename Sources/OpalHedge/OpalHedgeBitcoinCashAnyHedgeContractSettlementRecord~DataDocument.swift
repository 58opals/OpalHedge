// OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord~DataDocument.swift

import OpalHedgeBitcoinCash
import OpalHedgeCore

extension OpalHedgeBitcoinCashAnyHedgeContractSettlementRecord {
    public init(
        dataDocument: OpalHedgeCoreContractDataDocument,
        fundingIndex: Int = 0,
        network: OpalHedgeBitcoinCashNetwork = .mainnet,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode =
            .anyHedgeV0_12
    ) throws {
        let draftData = dataDocument.draftData
        guard draftData.fundings.indices.contains(fundingIndex) else {
            throw OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError
                .missingDataDocumentFunding(index: fundingIndex)
        }
        let funding = draftData.fundings[fundingIndex]
        guard let settlement = funding.settlement else {
            throw OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError
                .missingSettlement(index: fundingIndex)
        }

        let fundingRecord = try Self.fundingRecord(
            from: draftData,
            fundingIndex: fundingIndex,
            network: network,
            scriptBytecode: scriptBytecode
        )
        let settlementRequest = try OpalHedgeBitcoinCashAnyHedgeContractSettlementRequest(
            fundingRecord: fundingRecord,
            previousOracleProof: try Self.oracleProof(
                messageHex: settlement.previousMessageHex,
                signatureHex: settlement.previousSignatureHex,
                messageName: "previousMessage",
                signatureName: "previousSignature",
                fundingIndex: fundingIndex
            ),
            settlementOracleProof: try Self.oracleProof(
                messageHex: settlement.settlementMessageHex,
                signatureHex: settlement.settlementSignatureHex,
                messageName: "settlementMessage",
                signatureName: "settlementSignature",
                fundingIndex: fundingIndex
            )
        )
        let expectedRecord = try Self(
            settlementRequest: settlementRequest,
            settlementTransactionHash: settlement.settlementTransactionHash
        )
        guard expectedRecord.settlement == settlement else {
            throw OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError
                .inconsistentSettlement(
                    expected: expectedRecord.settlement,
                    actual: settlement
                )
        }

        self = expectedRecord
    }

    private static func fundingRecord(
        from draftData: OpalHedgeCoreContractDraftData,
        fundingIndex: Int,
        network: OpalHedgeBitcoinCashNetwork,
        scriptBytecode: OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode
    ) throws -> OpalHedgeBitcoinCashAnyHedgeContractFundingRecord {
        var fundings = draftData.fundings
        let funding = fundings[fundingIndex]
        fundings[fundingIndex] = OpalHedgeCoreContractFunding(
            fundingTransactionHash: funding.fundingTransactionHash,
            fundingOutputIndex: funding.fundingOutputIndex,
            fundingSatoshis: funding.fundingSatoshis
        )
        let fundingDataDocument = try OpalHedgeCoreContractDataDocument(
            draftData: OpalHedgeCoreContractDraftData(
                parameters: draftData.parameters,
                metadata: draftData.metadata,
                fundings: fundings,
                fees: draftData.fees
            )
        )

        return try OpalHedgeBitcoinCashAnyHedgeContractFundingRecord(
            dataDocument: fundingDataDocument,
            fundingIndex: fundingIndex,
            network: network,
            scriptBytecode: scriptBytecode
        )
    }

    private static func oracleProof(
        messageHex: String?,
        signatureHex: String?,
        messageName: String,
        signatureName: String,
        fundingIndex: Int
    ) throws -> OpalHedgeCoreContractSettlementOracleProof {
        guard let messageHex else {
            throw OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError
                .missingSettlementField(name: messageName, fundingIndex: fundingIndex)
        }
        guard let signatureHex else {
            throw OpalHedgeBitcoinCashAnyHedgeContractSettlementRecordError
                .missingSettlementField(name: signatureName, fundingIndex: fundingIndex)
        }

        return try OpalHedgeCoreContractSettlementOracleProof(
            messageHex: messageHex,
            signatureHex: signatureHex
        )
    }
}
