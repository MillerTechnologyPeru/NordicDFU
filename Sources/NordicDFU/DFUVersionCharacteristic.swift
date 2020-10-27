//
//  DFUVersionCharacteristic.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/21/18.
//

import Foundation
import Bluetooth
import GATT

/// DFU Version
public struct DFUVersionCharacteristic: GATTProfileCharacteristic, RawRepresentable {
    
    public static let uuid = BluetoothUUID(rawValue: "00001534-1212-EFDE-1523-785FEABCD123")!
    
    public static let service: GATTProfileService.Type = DFUService.self
    
    public static let properties: BitMaskOptionSet<GATT.CharacteristicProperty> = [.read]
    
    internal static let length = 2
    
    public var rawValue: DFUVersion
    
    public init(rawValue: DFUVersion) {
        
        self.rawValue = rawValue
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length
            else { return nil }
        
        let minor = data[0]
        let major = data[1]
        
        let version = DFUVersion(major: major, minor: minor)
        
        self.init(rawValue: version)
    }
    
    public var data: Data {
        
        return Data([rawValue.minor, rawValue.major])
    }
}

// MARK: - CustomStringConvertible

extension DFUVersionCharacteristic: CustomStringConvertible {
    
    public var description: String {
        
        return rawValue.description
    }
}
