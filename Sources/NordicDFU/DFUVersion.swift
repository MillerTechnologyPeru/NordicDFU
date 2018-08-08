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
public struct DFUVersion: GATTProfileCharacteristic {
    
    public static let uuid = BluetoothUUID.init(rawValue: "00001534-1212-EFDE-1523-785FEABCD123")!
    
    public static let service: GATTProfileService.Type = DFUService.self
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.read]
    
    internal static let length = 2
    
    public typealias Major = UInt8
    
    public typealias Minor = UInt8
    
    public var minor: Minor
    
    public var major: Major
    
    public init(minor: Minor,
                major: Major) {
        
        self.minor = minor
        self.major = major
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length
            else { return nil }
        
        self.minor = data[0]
        self.major = data[1]
    }
    
    public var data: Data {
        
        return Data([minor, major])
    }
}

// MARK: - CustomStringConvertible

extension DFUVersion: CustomStringConvertible {
    
    public var description: String {
        
        return "\(major).\(minor)"
    }
}
