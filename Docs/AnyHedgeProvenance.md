# AnyHedge v0.12 artifact provenance

OpalHedge's `Sources/OpalHedgeBitcoinCash/OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode.swift` embeds the 162-byte Bitcoin Cash contract program from General Protocols' AnyHedge contracts project. Its hexadecimal and byte-array representations are unchanged. This is protocol bytecode data used by the native Swift constructor encoder; no General Protocols JavaScript package or CashScript compiler is loaded at runtime.

| Binding | Value |
| --- | --- |
| Upstream project | [GeneralProtocols/anyhedge/contracts](https://gitlab.com/GeneralProtocols/anyhedge/contracts) |
| Verified upstream commit | [`9505f738486becfc297d42d91c4fc4685bec7a14`](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/tree/9505f738486becfc297d42d91c4fc4685bec7a14) |
| Contract source | [`contracts/v0.12/contract.cash`](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/contracts/v0.12/contract.cash), SHA-256 `8892bbd4784aa3f6944f41dee1b00faabc8d38a8ad33ba3991206b86b14c5a18` |
| Published compiled artifact | [`contracts/v0.12/artifact.json`](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/contracts/v0.12/artifact.json), SHA-256 `bc7dd9fdaba43fc97250dc74f59a24701d18a235d7f875ad880a6b6120c740fb` |
| Upstream artifact compiler metadata | `cashc` `0.9.2` |
| Embedded program | 162 bytes; SHA-256 `74418e6a1ca246ea9142f026d6a39a0683f0af0074b29c7fded89d3bdf723de6` |
| Upstream license | [MIT](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/LICENSE) |

The verified artifact's assembly decodes to the exact embedded program, including the `3405` data push. The predefined artifact descriptor now links to this immutable revision instead of the moving `development` branch; its public types, properties and initializer remain unchanged. This comparison records source and byte identity; it does not claim a reproducible `cashc` build, contract security audit, live deployment or funding qualification. Replacing or changing this program requires a separately reviewed protocol implementation and compatibility validation; this provenance notice makes no such replacement.

## Offline regression boundary

`OpalHedgeArtifactProvenanceValidator` binds the predefined descriptor URLs and this notice to the reviewed revision and hashes, and independently hashes the actual embedded program with Apple's CryptoKit. It also preserves the existing ten-week fixture's 181-byte constructor SHA-256, `1a52b2ea89aa5781ff14e52f56640543bb4ee210b378651f0540c7fa2abb4acd`. The existing golden-vector assertions continue to verify the constructor pushes, 343-byte redeem script, script hash `6cf774143b35046148a90f3f9024b2fd96541e5c`, address and contract document. These checks run offline; they do not fetch upstream files or invoke `cashc`.

The constructor digest records the existing local fixture inputs and output, not an independently reproduced upstream compilation. The current input qualification and compiler-chain evidence below narrow the remaining provenance limits without recovering the original import history.

## Ten-week fixture qualification

The thirteen constructor parameters exactly match `contract.createContract.output.parameters` in the [official library's `hedge10week.ts` at `bf87e6769abe8030b217fa00b4c346695dbd8055`](https://gitlab.com/GeneralProtocols/anyhedge/library/-/blob/bf87e6769abe8030b217fa00b4c346695dbd8055/test/fixture/use-cases/hedge10week.ts). That complete 7,942-byte file has SHA-256 `f5a514662f954ea9d47addace923a7e3ef43858697e6980674e95c084e8675ff`. The local v1 JSON uses `hedgeLockScript` and `hedgeMutualRedeemPublicKey`; only those names are mapped to the upstream `shortLockScript` and `shortMutualRedeemPublicKey` for comparison. Values are unchanged.

The offline parameter identity sorts the normalized names lexicographically and emits `name=value` plus LF for each of the thirteen fields. Integers use decimal notation and hexadecimal scripts/keys keep their existing lowercase spelling. SHA-256 is `cf3b0fe267a258d653015875a3d98dfa2a1b136c8516ca3f2e3270df64964a52`. The oracle public key, starting message and starting signature also match the pinned source exactly; their existing lowercase hexadecimal, in that order with one LF after each field, has SHA-256 `7ca40c8cabedd452386b508a12a01c4ba965a2e5975c983f3fa01944426c8a5a`.

Independent minimal Script-number/data-push encoding of those thirteen upstream values, in reverse constructor-declaration order, reproduces the current 181-byte constructor digest above. This checks the constructor data, not a CashScript compilation or consensus-VM execution. The existing local 343-byte redeem-script, P2SH20 hash/address and document assertions remain unchanged.

The full local fixture is not byte-identical to that current upstream use case: it retains a v1 `Hedge` schema and P2SH20 address, while the inspected source uses `short` terminology, additional metadata and a P2SH32 expected address. The upstream file itself says its initial on-chain example was manually updated over time. An adjacent older [v1 fixture at `fbbfa1983705127a0e086ee7841ab018811223c4`](https://gitlab.com/GeneralProtocols/anyhedge/library/-/blob/fbbfa1983705127a0e086ee7841ab018811223c4/test/fixture/use-cases/hedge10week.ts), SHA-256 `afba97ae02e47cbeee6c7f3679d4df84facf3e2a92bd5659a604ed2e234e2532`, has different maturity, payout and address values. Neither source establishes the original local JSON's import revision or generation command. Only the exact shared fields and independent constructor qualification above are claimed; no real transaction, deployment or funding claim follows. The referenced library fixture retains its [MIT notice](https://gitlab.com/GeneralProtocols/anyhedge/library/-/blob/bf87e6769abe8030b217fa00b4c346695dbd8055/LICENSE), Copyright (c) 2019 GeneralProtocols / AnyHedge.

## Compiler dependency-chain evidence and limit

The following official files are bound to the same contract revision `9505f738486becfc297d42d91c4fc4685bec7a14`. They describe upstream development and publication; they are not dependencies installed or executed by OpalHedge.

| Official file | SHA-256 | Relevant content |
| --- | --- | --- |
| [package.json](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/package.json) | `54c48b616d478b0c945160cfd883ea110efe9e4ba64a4c4c0f8e66db32c59028` | `cashc` and `cashscript` requirements `^0.9.2`; scripts only lint and spellcheck. |
| [package-lock.json](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/package-lock.json) | `57be465842d82933dbb4d28c03797582db79a086cd943b4621799e837f87c4ca` | Resolves `cashc` **0.9.3**, including its registry tarball integrity and transitive dependencies. |
| [.gitlab-ci.yml](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/.gitlab-ci.yml) | `dfa9686ad43748535aee30ee7caf0b88d3ff0d72e115ef76eebb49b27a484e45` | Installs with lifecycle scripts disabled, audits, lints, spellchecks and publishes; no contract compilation step. |
| [README.md](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/README.md) | `e8adab4afdbb56ccf949c6f9c7c69974ccd2fe43cc05dfd6c6f43dd884d07405` | Describes stored versioned source/artifacts; no compiler invocation or options. |
| [LICENSE](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/LICENSE) | `16c9e69f54e23906a34bb659a3909b78fc1864a20550a509ae7c94d317f40719` | MIT notice retained below. |

The published artifact says `cashc` **0.9.2**, so the 0.9.3 lock is not an established reproduction recipe for that artifact. Bounded history inspection found the last artifact change at [`d47463f92d0f5cde9b17198517c908d55b4b26ff`](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/commit/d47463f92d0f5cde9b17198517c908d55b4b26ff): its manifest requires `^0.9.2`, but it has no committed package lock. The artifact-introduction commit [`8de8ab535f9ac353b0af1f1232d324d7d909afd4`](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/commit/8de8ab535f9ac353b0af1f1232d324d7d909afd4) requires `^0.9.1` and also has no committed lock. Their CI files likewise do not record compilation. The artifact does not embed the contract source. Exact compiler executable/dependency inputs, invocation/options and reproducible source-to-bytecode compilation therefore remain unresolved. No npm tooling was installed or run, and no compiler reproduction or VM-equivalence claim is made.

The following upstream notice is retained verbatim for the embedded program. OpalHedge's own Swift implementation remains under its root [Apache-2.0 license](../LICENSE).

```text
MIT License

Copyright (c) 2020 GeneralProtocols / AnyHedge

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
