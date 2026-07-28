# Changelog

## Unreleased

- Added this changelog to track notable public-facing package changes.
- Switched `OpalDiagnostics` from its development branch to a stable `0.2.0`-or-newer package requirement.
- Updated the `OpalCrypto` SwiftPM branch pin to the latest `develop` revision.

## Pilot Baseline - 2026-07-05

- Established Opal Hedge as a Swift-native, AnyHedge-compatible Bitcoin Cash hedge contract package for apps, wallets, and server-side Swift.
- Added facade-first public API namespaces for `Core`, `Oracle`, `BitcoinCash`, and `Client`, backed by focused implementation targets.
- Added deterministic contract planning, contract data document encoding and decoding, funding and fee validation, settlement calculation, and lifecycle review values.
- Added oracle price message parsing and signature verification through `OpalCrypto`, with package diagnostics through `OpalDiagnostics`.
- Added Bitcoin Cash support for AnyHedge v0.12 script bytecode composition, constructor parameter encoding, P2SH CashAddr derivation, funding records, settlement records, and settlement summaries.
- Added the Opal Wallet Pilot integration boundary, routing wallet-facing integration through Opal Base while keeping transaction signing, broadcast, UI, liquidity provider discovery, merchant invoicing, and early settlement flows out of this package.
- Added Swift Testing coverage for upstream AnyHedge fixture compatibility, golden contract data documents, oracle proofs, payout math, Bitcoin Cash contract artifacts, lifecycle values, and diagnostics integration.
