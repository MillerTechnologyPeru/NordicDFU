//
//  SecureDFUResponse.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

import Foundation

/*
public enum SecureDFUResponse {
    
    public static let opcode: SecureDFUOpcode = .response
    
    case success(request: SecureDFUOpcode)
    case error(SecureDFUError)
    case extendedError(SecureDFUExtendedError)
}
*/

public protocol SecureDFUResponseProtocol {
    
    var request: SecureDFUOpcode { get }
    
    var status: SecureDFUResultCode { get }
    
    init?(data: Data)
    
    var data: Data { get }
}

public extension SecureDFUResponseProtocol {
    
    static var opcode: SecureDFUOpcode { return .response }
}

public struct SecureDFUResponse: SecureDFUResponseProtocol {
    
    internal static let length = 3
    
    public let request: SecureDFUOpcode
    
    public let status: SecureDFUResultCode
    
    public init?(data: Data) {
        
        guard data.count >= type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = SecureDFUOpcode(rawValue: data[1]),
            let status = SecureDFUResultCode(rawValue: data[2])
            else { return nil }
        
        self.request = request
        self.status = status
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue, request.rawValue, status.rawValue])
    }
}

public struct SecureDFUExtendedErrorResponse: SecureDFUResponseProtocol {
    
    internal static let length = 3
    
    public let request: SecureDFUOpcode
    
    public var status: SecureDFUResultCode { return .extendedError }
    
    public let error: SecureDFUExtendedError
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = SecureDFUOpcode(rawValue: data[1]),
            let status = SecureDFUResultCode(rawValue: data[2]),
            status == .extendedError,
            let error = SecureDFUExtendedError(rawValue: data[3])
            else { return nil }
        
        self.request = request
        self.error = error
    }
    
    public var data: Data {
        
        return Data([
            type(of: self).opcode.rawValue,
            request.rawValue,
            status.rawValue,
            error.rawValue
            ])
    }
}

public struct SecureDFUReadObjectInfoResponse: SecureDFUResponseProtocol {
    
    // The correct reponse for Read Object Info has additional 12 bytes: Max Object Size, Offset and CRC
    internal static let length = 3 + 12
    
    public var request: SecureDFUOpcode { return .readObjectInfo }
    
    public var status: SecureDFUResultCode { return .success }
    
    public let maxSize: UInt32
    
    public let offset: UInt32
    
    public let crc: UInt32
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = SecureDFUOpcode(rawValue: data[1]),
            request == .readObjectInfo,
            let status = SecureDFUResultCode(rawValue: data[2]),
            status == .success
            else { return nil }
        
        self.maxSize = UInt32(littleEndian: UInt32(bytes: (data[3], data[4], data[5], data[6])))
        self.offset = UInt32(littleEndian: UInt32(bytes: (data[7], data[8], data[9], data[10])))
        self.crc = UInt32(littleEndian: UInt32(bytes: (data[11], data[12], data[13], data[14])))
    }
    
    public var data: Data {
        
        let maxSizeBytes = maxSize.littleEndian.bytes
        let offsetBytes = offset.littleEndian.bytes
        let crcBytes = crc.littleEndian.bytes
        
        return Data([
            type(of: self).opcode.rawValue,
            request.rawValue,
            status.rawValue,
            maxSizeBytes.0,
            maxSizeBytes.1,
            maxSizeBytes.2,
            maxSizeBytes.3,
            offsetBytes.0,
            offsetBytes.1,
            offsetBytes.2,
            offsetBytes.3,
            crcBytes.0,
            crcBytes.1,
            crcBytes.2,
            crcBytes.3,
            ])
    }
}

public struct SecureDFUCalculateChecksumResponse: SecureDFUResponseProtocol {
    
    // The correct reponse for Calculate Checksum has additional 8 bytes: Offset and CRC
    internal static let length = 3 + 8
    
    public var request: SecureDFUOpcode { return .calculateChecksum }
    
    public var status: SecureDFUResultCode { return .success }
    
    public let offset: UInt32
    
    public let crc: UInt32
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = SecureDFUOpcode(rawValue: data[1]),
            request == .calculateChecksum,
            let status = SecureDFUResultCode(rawValue: data[2]),
            status == .success
            else { return nil }
        
        self.offset = UInt32(littleEndian: UInt32(bytes: (data[3], data[4], data[5], data[6])))
        self.crc = UInt32(littleEndian: UInt32(bytes: (data[7], data[8], data[9], data[10])))
    }
    
    public var data: Data {
        
        let offsetBytes = offset.littleEndian.bytes
        let crcBytes = crc.littleEndian.bytes
        
        return Data([
            type(of: self).opcode.rawValue,
            request.rawValue,
            status.rawValue,
            offsetBytes.0,
            offsetBytes.1,
            offsetBytes.2,
            offsetBytes.3,
            crcBytes.0,
            crcBytes.1,
            crcBytes.2,
            crcBytes.3,
            ])
    }
}

