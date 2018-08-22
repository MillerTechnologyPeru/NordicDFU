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

// MARK: - Float Conversion

internal extension DFUVersion {
    
    init(floatValue: Float) {
        
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

// MARK: - Equatable

extension DFUVersion: Equatable {
    
    public static func == (lhs: DFUVersion, rhs: DFUVersion) -> Bool {
        
        return lhs.major == rhs.major
            && lhs.minor == rhs.minor
    }
}

// MARK: - CustomStringConvertible

extension DFUVersion: CustomStringConvertible {
    
    public var description: String {
        
        return "\(major).\(minor)"
    }
}

// MARK: -

extension DFUVersion: ExpressibleByFloatLiteral {
    
    public init(floatLiteral floatValue: Float) {
        
        self.init(floatValue: floatValue)
    }
}

// MARK: - Codable

extension DFUVersion: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        let rawValue = try container.decode(Float.self)
        
        self.init(floatValue: rawValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        
    }
}
