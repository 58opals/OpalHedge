# AnyHedge v0.12 artifact provenance

OpalHedge's `Sources/OpalHedgeBitcoinCash/OpalHedgeBitcoinCashAnyHedgeContractScriptBytecode.swift` embeds the 162-byte Bitcoin Cash contract program from General Protocols' AnyHedge contracts project. Its hexadecimal and byte-array representations are unchanged. This is protocol bytecode data used by the native Swift constructor encoder; no General Protocols JavaScript package or CashScript compiler is loaded at runtime.

| Binding | Value |
| --- | --- |
| Upstream project | [GeneralProtocols/anyhedge/contracts](https://gitlab.com/GeneralProtocols/anyhedge/contracts) |
| Verified upstream commit | [`9505f738486becfc297d42d91c4fc4685bec7a14`](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/tree/9505f738486becfc297d42d91c4fc4685bec7a14) |
| Contract source | [`contracts/v0.12/contract.cash`](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/contracts/v0.12/contract.cash) |
| Published compiled artifact | [`contracts/v0.12/artifact.json`](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/contracts/v0.12/artifact.json), SHA-256 `bc7dd9fdaba43fc97250dc74f59a24701d18a235d7f875ad880a6b6120c740fb` |
| Upstream artifact compiler metadata | `cashc` `0.9.2` |
| Embedded program | 162 bytes; SHA-256 `74418e6a1ca246ea9142f026d6a39a0683f0af0074b29c7fded89d3bdf723de6` |
| Upstream license | [MIT](https://gitlab.com/GeneralProtocols/anyhedge/contracts/-/blob/9505f738486becfc297d42d91c4fc4685bec7a14/LICENSE) |

The verified artifact's assembly decodes to the exact embedded program, including the `3405` data push. This comparison records source and byte identity; it does not claim a reproducible compiler build, contract audit, live deployment or funding qualification. Existing public artifact URLs and APIs remain unchanged. Replacing or changing this program requires a separately reviewed protocol implementation and compatibility validation; this provenance notice makes no such replacement.

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
