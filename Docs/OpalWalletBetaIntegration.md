# Opal Wallet Beta Integration

Opal Hedge is ready for Opal Wallet beta integration as a deterministic AnyHedge-compatible protocol and data library. The beta boundary is intentionally narrow: Opal Hedge prepares and verifies hedge contract data, while Opal Wallet remains responsible for wallet custody, transaction construction, signing, broadcast, persistence, and user experience.

## Supported Boundary

Opal Hedge currently supports these integration surfaces:

- Build a `ContractCreationContext` from verified oracle proofs, payout addresses, locking scripts, mutual redemption public keys, and concrete timing values.
- Derive a reusable `ContractPlan` once and pass that plan through funding and settlement APIs.
- Create AnyHedge-compatible contract parameter data, bytecode artifacts, P2SH CashAddr funding outputs, funding requests, funding records, settlement requests, settlement records, settlement summaries, lifecycle states, and JSON data documents.
- Parse and verify starting and settlement oracle proofs.
- Calculate hedge-side payout amounts for maturation and liquidation paths.
- Use the first product preset for USD, hedge-side, thirty day simple hedge defaults.
- Reconstruct funding and settlement records from Opal Hedge data documents.

## Wallet Responsibilities

Opal Wallet should own these responsibilities during beta integration:

- Obtain oracle messages and signatures from the selected oracle source.
- Produce payout addresses, lock scripts, and mutual redemption public keys from wallet-owned key material.
- Select UTXOs, construct transactions, estimate fees, sign inputs, broadcast transactions, and monitor confirmations.
- Persist wallet-visible hedge state and associate it with wallet transactions.
- Decide product availability, risk copy, kill switches, user confirmation flows, and mainnet rollout controls.
- Keep transaction signing and broadcast behind wallet-owned beta gates until end-to-end transaction tests are complete.

## Suggested Integration Flow

1. Verify the starting oracle proof with `OpalHedge.Oracle.verifyStartingPriceProof`.
2. Create `OpalHedge.Core.ContractCreationContext` with wallet-owned addresses, scripts, keys, and contract terms.
3. Derive `OpalHedge.Core.ContractPlan` once and persist the plan inputs needed to recreate it.
4. Use `OpalHedge.Client.Context` to create the funding request and display the contract funding output.
5. After the funding transaction exists, create the funding record from the same contract plan plus the funding transaction hash and output index.
6. Verify settlement oracle proofs and create the settlement summary or settlement record from the same contract plan plus wallet-observed settlement data.
7. Persist the produced data document as the portable AnyHedge-compatible contract record.

## Beta Acceptance Checklist

Before exposing the integration to beta users, Opal Wallet should verify:

- A wallet integration test can create the same funding output address and satoshi amount from stable fixture inputs.
- Funding request JSON is persisted and can be reconstructed into equivalent funding data.
- Settlement summary calculation matches expected maturation and liquidation fixture outcomes.
- Wallet transaction signing and broadcast are covered outside Opal Hedge.
- Mainnet availability is gated by an explicit Opal Wallet beta switch.
- User-visible copy does not imply Opal Hedge signs, broadcasts, escrows, or manages liquidity.

The package test suite includes `OpalHedgeWalletBetaIntegrationValidator` as the baseline fixture for stable funding output, funding document reconstruction, and settlement summary reconstruction.

## Out Of Scope For This Package

The beta library does not provide transaction signing, transaction broadcast, liquidity provider discovery, merchant invoicing, wallet UI, early settlement UX, or custom leverage controls.
