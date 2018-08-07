//
//  DFUResponse.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation

/// DFU Response
public struct DFUResponse: DFUMessage {
    
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
    
    public init(request: DFUOpcode,
                error: DFUError? = nil) {
        
        self.init(request: request, status: error?.code ?? .success)
    }
    
    internal init(request: DFUOpcode,
                  status: DFUResultCode = .success) {
        
        self.request = request
        self.status = status
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
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue, request.rawValue, status.rawValue])
    }
}

extension DFUResponse: Equatable {
    
    public static func == (lhs: DFUResponse, rhs: DFUResponse) -> Bool {
        
        return lhs.request == rhs.request
            && lhs.status == rhs.status
    }
}
