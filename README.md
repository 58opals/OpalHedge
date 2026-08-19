# Opal Hedge

Swift-native, AnyHedge-compatible Bitcoin Cash hedge contract library for apps, wallets, and server-side Swift.

Opal Hedge is an open-source Swift package for building AnyHedge-compatible Bitcoin Cash hedge contract functionality. It is intended for Swift developers who want native BCH value-locking primitives without JavaScript, WebView, or dependency on General Protocols runtime code. The project goal is an independent Swift implementation that remains compatible at the protocol layer.

## Status

Status: Pilot on develop.

This package is in Pilot for Opal Wallet integration as a protocol and data library. The current focus is deterministic AnyHedge-compatible data, oracle proof handling, payout math, contract bytecode artifacts, funding data, settlement data, and plan-first client APIs.

See [Changelog](CHANGELOG.md) for notable public-facing package changes.

For the Opal Wallet Pilot path, the intended dependency route is `OpalHedge` into `OpalBase`, then Opal Wallet consumes the wallet-facing hedge facade exposed by Opal Base. Opal Hedge owns protocol data and verification. Opal Base owns reusable wallet integration, transaction construction, signing, broadcast, and Bitcoin Cash app-domain adapters. Opal Wallet owns product UI, Pilot gates, copy, routing, and app persistence policy.

Currently supported:

- AnyHedge-compatible metadata, parameter, funding, fee, and settlement data.
- Price oracle message parsing and signature verification.
- Hedge-side payout calculation for maturation and liquidation paths.
- AnyHedge v0.12 script bytecode composition and constructor parameter encoding.
- P2SH CashAddr contract address derivation for Bitcoin Cash networks.
- Funding request, funding record, settlement request, settlement record, and settlement summary value types.
- USD simple hedge thirty day policy defaults.
- Golden tests against upstream AnyHedge-style fixture data.

Not yet supported:

- Transaction signing.
- Transaction broadcast.
- Wallet UI.
- Liquidity provider discovery.
- Merchant invoicing.
- Early settlement user flows.

See [Opal Wallet Pilot Integration](Docs/OpalWalletPilotIntegration.md) for the supported integration boundary and checklist.

## Requirements

- Swift tools version: `6.4`
- Platforms: `macOS 26`, `iOS 26`, `watchOS 26`, `tvOS 26`, `visionOS 26`
- Xcode's Metal Toolchain component, required by the current OpalCrypto build plugin.

## Installation

Add Opal Hedge as a SwiftPM dependency from reusable Bitcoin Cash infrastructure packages, integration test harnesses, or server-side Swift code:

```swift
.package(
    url: "https://github.com/58opals/OpalHedge.git",
    branch: "develop"
)
```

The current manifest follows `OpalCrypto` and `OpalDiagnostics` on their public `develop` branches. No SemVer tag is prepared by this migration.

Then depend on the `OpalHedge` library product:

```swift
.product(name: "OpalHedge", package: "OpalHedge")
```

The package exposes one umbrella module:

```swift
import OpalHedge
```

Opal Wallet should normally consume Opal Hedge through Opal Base rather than adding this package directly to the app target. A direct Opal Wallet dependency is appropriate only for a short-lived spike or fixture comparison before the Opal Base adapter exists.

## Public API Shape

The public facade is organized by domain:

```swift
OpalHedge.Core
OpalHedge.Oracle
OpalHedge.BitcoinCash
OpalHedge.Client
```

The package also contains implementation targets named `OpalHedgeCore`, `OpalHedgeOracle`, `OpalHedgeBitcoinCash`, and `OpalHedgeClient`. Application code should prefer the umbrella `OpalHedge` module unless it needs a specific implementation target.

## Quick Start

Verify a starting oracle proof:

```swift
let startingProof = try OpalHedge.Oracle.verifyStartingPriceProof(
    messageHex: startingOracleMessageHex,
    signatureHex: startingOracleSignatureHex,
    publicKeyHex: oraclePublicKeyHex
)
```

Create a contract creation context and derive a reusable contract plan:

```swift
let creationContext = try OpalHedge.Core.ContractCreationContext(
    takerSide: .short,
    makerSide: .long,
    startingOracleProof: startingProof,
    shortPayoutAddress: "bitcoincash:qq59hv6s3qdjrtyfwfxxldkuj9xsjmx48vrz882knz",
    longPayoutAddress: "bitcoincash:qpzlruwy4xu5rxjs3z37nsj29y7h59gwvsu4ddp0u4",
    shortLockScriptHex: shortLockScriptHex,
    longLockScriptHex: longLockScriptHex,
    nominalUnits: 1_000,
    maturityTimestamp: maturityTimestamp,
    isSimpleHedge: 1,
    highLiquidationPriceMultiplier: 10,
    lowLiquidationPriceMultiplier: 0.75,
    enableMutualRedemption: 1,
    shortMutualRedeemPublicKeyHex: shortMutualRedeemPublicKeyHex,
    longMutualRedeemPublicKeyHex: longMutualRedeemPublicKeyHex,
    minerCostInSatoshis: 632
)

let contractPlan = try OpalHedge.Core.ContractPlan(
    from: creationContext
)
```

Build AnyHedge-compatible funding data:

```swift
let clientContext = OpalHedge.Client.Context()
let fundingRequest = try clientContext.createAnyHedgeContractFundingRequest(
    from: contractPlan,
    network: .mainnet
)

let fundingOutput = fundingRequest.fundingOutput

print(fundingOutput.contractAddress.rawValue)
print(fundingOutput.satoshis)
print(fundingRequest.contractDataDocument.jsonText)
```

Record the funding transaction output after it exists:

```swift
let fundingRecord = try clientContext.createAnyHedgeContractFundingRecord(
    from: contractPlan,
    fundingTransactionHash: fundingTransactionHash,
    fundingOutputIndex: fundingOutputIndex
)
```

Create settlement data from verified oracle proofs:

```swift
let previousOracleProof = try OpalHedge.Oracle.verifySettlementOracleProof(
    messageHex: previousOracleMessageHex,
    signatureHex: previousOracleSignatureHex,
    publicKeyHex: oraclePublicKeyHex
)
let settlementOracleProof = try OpalHedge.Oracle.verifySettlementOracleProof(
    messageHex: settlementOracleMessageHex,
    signatureHex: settlementOracleSignatureHex,
    publicKeyHex: oraclePublicKeyHex
)

let settlementSummary = try clientContext.createAnyHedgeContractSettlementSummary(
    from: contractPlan,
    fundingTransactionHash: fundingTransactionHash,
    fundingOutputIndex: fundingOutputIndex,
    previousOracleProof: previousOracleProof,
    settlementOracleProof: settlementOracleProof,
    settlementTransactionHash: settlementTransactionHash
)

print(settlementSummary.settlementKind)
print(settlementSummary.hedgePayoutInSatoshis)
print(settlementSummary.longPayoutInSatoshis)
print(settlementSummary.dataDocument.jsonText)
```

## Presets

The first product slice includes a fixed USD, hedge-side, thirty day preset:

```swift
let preset = OpalHedge.Core.ContractPreset.usdSimpleHedgeThirtyDay
```

The preset describes policy defaults. Contract creation still requires concrete oracle proofs, payout addresses, locking scripts, mutual redemption public keys, and timing values.

## License

Opal Hedge is available under the [Apache License 2.0](LICENSE).

## Validation

Current validation command:

```sh
swift test
```

Result: Passed on 2026-07-05 with 276 tests in 48 suites.

## Development

Run the test suite:

```sh
swift test
```

The tests use Swift Testing and cover oracle parsing, oracle signature verification, contract planning, payout math, AnyHedge contract data documents, constructor parameter encoding, script bytecode composition, CashAddr derivation, funding lifecycle values, and settlement lifecycle values.
