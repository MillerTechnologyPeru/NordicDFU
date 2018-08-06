//
//  DFUResponse.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation

/// DFU Response
public protocol DFUResponseProtocol {
    
    /// Response Opcode
    static var opcode: DFUOpcode { get }
    
    /// Initialize from PDU bytes.
    init?(data: Data)
}

/// DFU Response
public struct DFUResponse: DFUResponseProtocol {
    
    public static let opcode: DFUOpcode = .response
    
    internal static let length = 3
    
    /// The request that issued this reponse.
    public let request: DFUOpcode
    
    /// Status Code
    internal let status: DFUResultCode
    
    /// Error
    public var error: DFUError? {
        
        return DFUError(code: status)
    }
    
    public init?(data: Data) {
        
        guard data.count == DFUResponse.length,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == DFUResponse.opcode,
            let request = DFUOpcode(rawValue: data[1]),
            let status = DFUResultCode(rawValue: data[2])
            else { return nil }
        
        self.request = request
        self.status = status
    }
}
