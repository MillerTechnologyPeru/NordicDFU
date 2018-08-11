//
//  SecureDFUResponse.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

import Foundation

public enum SecureDFUResponse {
    
    public static let opcode: SecureDFUOpcode = .response
    
    case success(request: SecureDFUOpcode)
    case error(SecureDFUError)
    case extendedError(SecureDFUExtendedError)
}

public protocol SecureDFUResponseProtocol {
    
    var request: SecureDFUOpcode { get }
    
    static var status: SecureDFUResultCode { get }
    
    init?(data: Data)
    
    var data: Data { get }
}

public extension SecureDFUResponseProtocol {
    
    static var opcode: SecureDFUOpcode { return .response }
}

public struct SecureDFUSuccessResponse: SecureDFUResponseProtocol {
    
    internal static let length = 3
    
    public static let status: SecureDFUResultCode = .success
    
    public let request: SecureDFUOpcode
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = SecureDFUOpcode(rawValue: data[1]),
            let status = SecureDFUResultCode(rawValue: data[2]),
            status == type(of: self).status
            else { return nil }
        
        self.request = request
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue, request.rawValue, type(of: self).status.rawValue])
    }
}

internal struct SecureDFUResponseHeader {
    
    internal static let length = 3
    
    static let opcode: SecureDFUOpcode = .response
    
    let request: SecureDFUOpcode
    
    let status: SecureDFUResultCode
    
    init?(data: Data) {
        
        guard data.count >= type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = SecureDFUOpcode(rawValue: data[1]),
            let status = SecureDFUResultCode(rawValue: data[2])
            else { return nil }
        
        self.request = request
        self.status = status
    }
}

internal struct SecureDFUGenericResponse {
    
    let header: SecureDFUResponseHeader
    
    let payload: Data
    
    init?(data: Data) {
        
        guard let header = SecureDFUResponseHeader(data: data)
            else { return nil }
        
        self.header = header
        
        if data.count > SecureDFUResponseHeader.length {
            
            self.payload = Data(data.suffix(from: SecureDFUResponseHeader.length))
            
        } else {
            
            self.payload = Data()
        }
    }
}
