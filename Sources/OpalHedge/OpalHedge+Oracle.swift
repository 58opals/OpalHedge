// OpalHedge+Oracle.swift

import OpalHedgeOracle

extension OpalHedge {
    public enum Oracle {
        public typealias Context = OpalHedgeOracleContext
        public typealias MessageError = OpalHedgeOracleMessageError
        public typealias PriceMessage = OpalHedgeOraclePriceMessage
        public typealias SignatureVerificationError = OpalHedgeOracleSignatureVerificationError
        public typealias SignatureVerifier = OpalHedgeOracleSignatureVerifier
    }
}
