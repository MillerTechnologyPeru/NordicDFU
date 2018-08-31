//
//  SecureDFUResponse.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

import Foundation

public enum SecureDFUResponse {
    
    public static var opcode: SecureDFUOpcode { return .response }
    
    case success(SecureDFUSuccessResponse)
    case readObject(SecureDFUReadObjectInfoResponse)
    case calculateChecksum(SecureDFUCalculateChecksumResponse)
    
    case error(SecureDFUErrorResponse)
    case extendedError(SecureDFUExtendedErrorResponse)
}

public extension SecureDFUResponse {
    
    public var error: Error? {
        
        switch self {
        case let .error(response):
            return response.error
        case let .extendedError(response):
            return response.error
        default:
            return nil
        }
    }
}

// MARK: - RawRepresentable

extension SecureDFUResponse: RawRepresentable {
    
    public init?(rawValue: SecureDFUResponseProtocol) {
        
        if let rawValue = rawValue as? SecureDFUSuccessResponse {
            
            self = .success(rawValue)
            
        } else if let rawValue = rawValue as? SecureDFUErrorResponse {
            
            self = .error(rawValue)
            
        } else if let rawValue = rawValue as? SecureDFUExtendedErrorResponse {
            
            self = .extendedError(rawValue)
            
        } else if let rawValue = rawValue as? SecureDFUReadObjectInfoResponse {
            
            self = .readObject(rawValue)
            
        } else if let rawValue = rawValue as? SecureDFUCalculateChecksumResponse {
            
            self = .calculateChecksum(rawValue)
            
        } else {
            
            return nil
        }
    }
    
    public var rawValue: SecureDFUResponseProtocol {
        
        switch self {
        case let .success(response): return response
        case let .error(response): return response
        case let .extendedError(response): return response
        case let .readObject(response): return response
        case let .calculateChecksum(response): return response
        }
    }
}

// MARK: - Data

public extension SecureDFUResponse {
    
    internal static let length = 3
    
    public init?(data: Data) {
        
        guard data.count >= type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = SecureDFUOpcode(rawValue: data[1]),
            let status = SecureDFUResultCode(rawValue: data[2])
            else { return nil }
        
        switch (status, request) {
            
        case (.success, .readObjectInfo):
            
            guard let value = SecureDFUReadObjectInfoResponse(data: data)
                else { return nil }
            
            self = .readObject(value)
            
        case (.success, .calculateChecksum):
            
            guard let value = SecureDFUCalculateChecksumResponse(data: data)
                else { return nil }
            
            self = .calculateChecksum(value)
            
        case (.success, _):
            
            guard let value = SecureDFUSuccessResponse(data: data)
                else { return nil }
            
            self = .success(value)
            
        case (.extendedError, _):
            
            guard let value = SecureDFUExtendedErrorResponse(data: data)
                else { return nil }
            
            self = .extendedError(value)
            
        default:
            
            guard let value = SecureDFUErrorResponse(data: data)
                else { return nil }
            
            self = .error(value)
        }
    }
    
    public var data: Data {
        
        return rawValue.data
    }
}

// MARK: - SecureDFUResponseProtocol

public protocol SecureDFUResponseProtocol {
    
    var request: SecureDFUOpcode { get }
    
    var status: SecureDFUResultCode { get }
    
    init?(data: Data)
    
    var data: Data { get }
}

public extension SecureDFUResponseProtocol {
    
    static var opcode: SecureDFUOpcode { return .response }
}

public struct SecureDFUSuccessResponse: SecureDFUResponseProtocol {
    
    internal static let length = 3
    
    public let request: SecureDFUOpcode
    
    public var status: SecureDFUResultCode { return .success }
    
    public init(request: SecureDFUOpcode) {
        
        self.request = request
    }
    
    public init?(data: Data) {
        
        guard data.count >= type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = SecureDFUOpcode(rawValue: data[1]),
            let status = SecureDFUResultCode(rawValue: data[2]),
            status == .success
            else { return nil }
        
        self.request = request
    }
    
    public var data: Data {
        
        return Data([
            type(of: self).opcode.rawValue,
            request.rawValue,
            status.rawValue
            ])
    }
}

public struct SecureDFUErrorResponse: SecureDFUResponseProtocol, Error {
    
    internal static let length = 3
    
    public let request: SecureDFUOpcode
    
    public var status: SecureDFUResultCode { return error.code }
    
    public let error: SecureDFUError
    
    public init(request: SecureDFUOpcode,
                error: SecureDFUError) {
        
        self.request = request
        self.error = error
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let request = SecureDFUOpcode(rawValue: data[1]),
            let status = SecureDFUResultCode(rawValue: data[2]),
            let error = SecureDFUError(code: status)
            else { return nil }
        
        self.request = request
        self.error = error
    }
    
    public var data: Data {
        
        return Data([
            type(of: self).opcode.rawValue,
            request.rawValue,
            status.rawValue
            ])
    }
}

public struct SecureDFUExtendedErrorResponse: SecureDFUResponseProtocol, Error {
    
    internal static let length = 3
    
    public let request: SecureDFUOpcode
    
    public var status: SecureDFUResultCode { return .extendedError }
    
    public let error: SecureDFUExtendedError
    
    public init(request: SecureDFUOpcode,
                error: SecureDFUExtendedError) {
        
        self.request = request
        self.error = error
    }
    
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
    
    public init(maxSize: UInt32,
                offset: UInt32,
                crc: UInt32) {
        
        self.maxSize = maxSize
        self.offset = offset
        self.crc = crc
    }
    
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

public typealias SecureDFUPacketReceiptNotification = SecureDFUCalculateChecksumResponse

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

