//
//  ButtonlessDFUResponse.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/30/18.
//

import Foundation

public struct ButtonlessDFUResponse {
    
    public static let opcode: ButtonlessDFUOpCode = .response
    
    internal static let length = 3
    
    /// The request that issued this reponse.
    public let request: ButtonlessDFUOpCode
    
    /// Status Code
    @_versioned
    internal let status: ButtonlessDFUResultCode
    
    /// Error
    public var error: ButtonlessDFUError? {
        
        @inline(__always)
        get { return ButtonlessDFUError(code: status) }
    }
    
    public init(request: ButtonlessDFUOpCode,
                error: ButtonlessDFUError? = nil) {
        
        self.init(request: request, status: error?.code ?? .success)
    }
    
    internal init(request: ButtonlessDFUOpCode,
                  status: ButtonlessDFUResultCode = .success) {
        
        self.request = request
        self.status = status
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = ButtonlessDFUOpCode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = ButtonlessDFUOpCode(rawValue: data[1]),
            let status = ButtonlessDFUResultCode(rawValue: data[2])
            else { return nil }
        
        self.init(request: request, status: status)
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue, request.rawValue, status.rawValue])
    }
}

// MARK: - Equatable

extension ButtonlessDFUResponse: Equatable {
    
    public static func == (lhs: ButtonlessDFUResponse, rhs: ButtonlessDFUResponse) -> Bool {
        
        return lhs.request == rhs.request
            && lhs.status == rhs.status
    }
}
