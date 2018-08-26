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
        
        let size = data.withUnsafeBytes { UInt32(littleEndian: $0.advanced(by: 2).pointee) }
        
        self.type = type
        self.size = size
    }
    
    public var data: Data {
        
        let sizeBytes = size.littleEndian.bytes
        
        return Data([
            type(of: self).opcode.rawValue,
            type.rawValue,
            sizeBytes.0,
            sizeBytes.1,
            sizeBytes.2,
            sizeBytes.3,
            ])
        
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
        
        let rawValue = data.withUnsafeBytes { UInt16(littleEndian: $0.advanced(by: 1).pointee) }
        
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
