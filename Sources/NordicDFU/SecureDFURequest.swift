//
//  SecureDFURequest.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

import Foundation

public enum SecureDFURequest {
    
    case createObject(SecureDFUCreateObject)
    case setPRNValue(SecureDFUSetPacketReceiptNotification)
    case calculateChecksum
    case execute
    case readObjectInfo(SecureDFUReadObjectInfo)
}

internal extension SecureDFURequest {
    
    var data: Data {
        
        switch self {
        case let .createObject(request):
            return request.data
        case let .setPRNValue(request):
            return request.data
        case .calculateChecksum:
            return SecureDFUCalculateChecksumCommand().data
        case .execute:
            return SecureDFUExecuteCommand().data
        case let .readObjectInfo(request):
            return request.data
        }
    }
}

public protocol SecureDFURequestProtocol {
    
    /// DFU Opcode
    static var opcode: SecureDFUOpcode { get }
    
    /// Initialize from PDU bytes.
    init?(data: Data)
    
    /// Request PDU data.
    var data: Data { get }
}

public struct SecureDFUCreateObject: SecureDFURequestProtocol {
    
    public static let opcode: SecureDFUOpcode = .createObject
    
    internal static let length = 1 + 1 + MemoryLayout<UInt32>.size
    
    public var type: SecureDFUProcedureType
    
    public var size: UInt32
    
    public init(type: SecureDFUProcedureType, size: UInt32) {
        
        self.type = type
        self.size = size
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let type = SecureDFUProcedureType(rawValue: data[1])
            else { return nil }
        
        let size = UInt32(littleEndian: UInt32(bytes: (data[2], data[3], data[4], data[5])))
        
        self.type = type
        self.size = size
    }
    
    public var data: Data {
        
        var data = Data(capacity: type(of: self).length)
        data += type(of: self).opcode.rawValue
        data += type.rawValue
        data += size.littleEndian
        return data
    }
}

public struct SecureDFUReadObjectInfo: SecureDFURequestProtocol {
    
    public static let opcode: SecureDFUOpcode = .readObjectInfo
    
    internal static let length = 1 + 1
    
    public var type: SecureDFUProcedureType
    
    public init(type: SecureDFUProcedureType) {
        
        self.type = type
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode,
            let type = SecureDFUProcedureType(rawValue: data[1])
            else { return nil }
        
        self.type = type
    }
    
    public var data: Data {
        
        return Data([
            type(of: self).opcode.rawValue,
            type.rawValue,
            ])
        
    }
}

public struct SecureDFUSetPacketReceiptNotification: SecureDFURequestProtocol {
    
    public static let opcode: SecureDFUOpcode = .setPRNValue
    
    internal static let length = 3
    
    public var rawValue: UInt16
    
    public init(rawValue: UInt16) {
        
        self.rawValue = rawValue
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
        
        let rawValue = UInt16(littleEndian: UInt16(bytes: (data[1], data[2])))
        
        self.init(rawValue: rawValue)
    }
    
    public var data: Data {
        
        let rawValueBytes = rawValue.littleEndian.bytes
        
        return Data([
            type(of: self).opcode.rawValue,
            rawValueBytes.0,
            rawValueBytes.1
            ])
        
    }
}

extension SecureDFUSetPacketReceiptNotification: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        
        self.init(rawValue: value)
    }
}

public struct SecureDFUCalculateChecksumCommand: SecureDFURequestProtocol {
    
    public static let opcode: SecureDFUOpcode = .calculateChecksum
    
    internal static let length = 1
    
    public init() { }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
        
        self.init()
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue])
    }
}

public struct SecureDFUExecuteCommand: SecureDFURequestProtocol {
    
    public static let opcode: SecureDFUOpcode = .execute
    
    internal static let length = 1
    
    public init() { }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = SecureDFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
        
        self.init()
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue])
    }
}
