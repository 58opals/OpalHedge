# Opal Wallet Beta Integration

Opal Hedge is ready for Opal Wallet beta integration as a deterministic AnyHedge-compatible protocol and data library. The beta boundary is intentionally narrow: Opal Hedge prepares and verifies hedge contract data. Opal Base should own the reusable wallet adapter and transaction boundary, while Opal Wallet should own product UI, beta gates, copy, routing, and app persistence policy.

## Supported Boundary

Opal Hedge currently supports these integration surfaces:

- Build a `ContractCreationContext` from verified oracle proofs, payout addresses, locking scripts, mutual redemption public keys, and concrete timing values.
- Derive a reusable `ContractPlan` once and pass that plan through funding and settlement APIs.
- Create AnyHedge-compatible contract parameter data, bytecode artifacts, P2SH CashAddr funding outputs, funding requests, funding records, settlement requests, settlement records, settlement summaries, lifecycle states, and JSON data documents.
- Parse and verify starting and settlement oracle proofs.
- Calculate hedge-side payout amounts for maturation and liquidation paths.
- Use the first product preset for USD, hedge-side, thirty day simple hedge defaults.
- Reconstruct funding and settlement records from Opal Hedge data documents.

## Recommended Dependency Path

The durable Opal Wallet beta path is:

1. Add `OpalHedge` to Opal Base on the beta lane.
2. Expose a small Opal Base hedge facade for wallet-facing flows.
3. Consume that Opal Base facade from Opal Wallet.

Opal Wallet should not normally add `OpalHedge` directly to the app target. A direct app dependency is acceptable only for a short-lived spike, fixture comparison, or migration aid before the Opal Base facade exists.

## Opal Base Responsibilities

Opal Base should own these responsibilities during beta integration:

- Adapt Opal Base wallet vocabulary such as addresses, satoshis, transaction hashes, UTXOs, network selection, and wallet-owned key material into Opal Hedge contract inputs.
- Produce payout addresses, locking scripts, and mutual redemption public keys from wallet-owned key material.
- Select UTXOs, construct transactions, estimate fees, sign inputs, broadcast transactions, and monitor confirmations.
- Provide the wallet-facing hedge facade that creates funding requests, records funding outputs, reconstructs persisted data documents, and summarizes settlement outcomes.
- Keep reusable Bitcoin Cash transaction and persistence behavior outside the Opal Wallet app target.

## Wallet Responsibilities

Opal Wallet should own these responsibilities during beta integration:

- Obtain oracle messages and signatures from the selected oracle source.
- Call the Opal Base hedge facade rather than importing Opal Hedge directly in durable app code.
- Persist wallet-visible hedge state according to app policy and associate it with wallet transactions.
- Decide product availability, risk copy, kill switches, user confirmation flows, and mainnet rollout controls.
- Keep transaction signing and broadcast behind wallet-owned beta gates until end-to-end transaction tests are complete.

## Suggested Integration Flow

1. Add `OpalHedge` to Opal Base and keep Opal Wallet dependent on Opal Base.
2. In Opal Base, verify the starting oracle proof with `OpalHedge.Oracle.verifyStartingPriceProof`.
3. Create `OpalHedge.Core.ContractCreationContext` from wallet-owned payout addresses, locking scripts, mutual redemption public keys, and contract terms.
4. Derive `OpalHedge.Core.ContractPlan` once and persist the plan inputs needed to recreate it.
5. Use `OpalHedge.Client.Context` inside the Opal Base adapter to create the funding request and return a wallet-facing funding output.
6. After the funding transaction exists, create the funding record from the same contract plan plus the funding transaction hash and output index.
7. Verify settlement oracle proofs and create the settlement summary or settlement record from the same contract plan plus wallet-observed settlement data.
8. Persist the produced data document as the portable AnyHedge-compatible contract record.

## Beta Acceptance Checklist

Before exposing the integration to beta users, Opal Wallet should verify:

- Opal Base exposes a hedge facade that hides direct Opal Hedge dependency details from durable app code.
- A wallet integration test can create the same funding output address and satoshi amount from stable fixture inputs.
- Funding request JSON is persisted and can be reconstructed into equivalent funding data.
- Settlement summary calculation matches expected maturation and liquidation fixture outcomes.
- Wallet transaction signing and broadcast are covered through Opal Base and remain outside Opal Hedge.
- Mainnet availability is gated by an explicit Opal Wallet beta switch.
- User-visible copy does not imply Opal Hedge signs, broadcasts, escrows, or manages liquidity.

The package test suite includes `OpalHedgeWalletBetaIntegrationValidator` as the baseline fixture for stable funding output, funding document reconstruction, and settlement summary reconstruction.

## Out Of Scope For This Package

The beta library does not provide transaction signing, transaction broadcast, liquidity provider discovery, merchant invoicing, wallet UI, early settlement UX, or custom leverage controls.
