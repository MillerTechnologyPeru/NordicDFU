//
//  ButtonlessDFURequest.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/29/18.
//

import Foundation

protocol ButtonlessDFURequestProtocol {
    
    static var opcode: ButtonlessDFUOpCode { get }
    
    init?(data: Data)
    
    var data: Data { get }
}

public struct ButtonlessDFUEnterBootloader: ButtonlessDFURequestProtocol {
    
    public static let opcode: ButtonlessDFUOpCode = .enterBootloader
    
    internal static let length = 1
    
    public init() { }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = ButtonlessDFUOpCode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue])
    }
}

public struct ButtonlessDFUSetName: ButtonlessDFURequestProtocol {
    
    public static let opcode: ButtonlessDFUOpCode = .setName
    
    /// Minimum length
    internal static let length = 2
    
    public let rawValue: String
    
    public init(rawValue: String) {
        
        self.rawValue = rawValue
    }
    
    public init?(data: Data) {
        
        guard data.count >= type(of: self).length,
            let opcode = ButtonlessDFUOpCode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
        
        let nameLength = Int(data[1])
        
        guard data.count == type(of: self).length + nameLength
            else { return nil } // not enough bytes
        
        guard let string = String(data: data.subdataNoCopy(in: 2 ..< 2 + nameLength), encoding: .utf8)
            else { return nil }
        
        self.init(rawValue: string)
    }
    
    public var data: Data {
        
        var data = Data(capacity: type(of: self).length + rawValue.utf8.count)
        data += type(of: self).opcode.rawValue
        data += UInt8(rawValue.utf8.count)
        data += rawValue.utf8
        
        return data
    }
}

extension ButtonlessDFUSetName: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        
        self.init(rawValue: value)
    }
}

extension ButtonlessDFUSetName: CustomStringConvertible {
    
    public var description: String {
        
        return rawValue
    }
}
