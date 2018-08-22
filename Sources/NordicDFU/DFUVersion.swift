//
//  DFUVersion.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/7/18.
//

import Foundation
import Bluetooth
import GATT

/// DFU Version
public struct DFUVersion {
    
    public typealias Major = UInt8
    
    public typealias Minor = UInt8
    
    public var major: Major
    
    public var minor: Minor
    
    public init(major: Major,
                minor: Minor) {
        
        self.major = major
        self.minor = minor
    }
}

internal extension DFUVersion {
    
    init(_ floatValue: Float) {
        
        let components = "\(floatValue)".components(separatedBy: ".")
        
        guard components.count == 2,
            let major = Major(components[0]),
            let minor = Minor(components[1])
            else { fatalError("Invalid float value \(floatValue)") }
        
        self.init(major: minor, minor: major)
    }
    
    var floatValue: Float {
        
        return Float(description)!
    }
}

// MARK: - CustomStringConvertible

extension DFUVersion: CustomStringConvertible {
    
    public var description: String {
        
        return "\(major).\(minor)"
    }
}

// MARK: - Codable

extension DFUVersion: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        let rawValue = try container.decode(Float.self)
        
        self.init(rawValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        
    }
}
