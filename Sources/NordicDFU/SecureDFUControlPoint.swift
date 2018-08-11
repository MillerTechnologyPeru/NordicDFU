//
//  SecureDFUControlPoint.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

import Foundation
import Bluetooth

public struct SecureDFUControlPoint: GATTProfileCharacteristic {
    
    public static let uuid = BluetoothUUID(rawValue: "8EC90001-F315-4F60-9FB8-838830DAEA50")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.write, .notify]
    
    public static var service: GATTProfileService.Type = SecureDFUService.self
    
    public init?(data: Data) {
        
        fatalError()
    }
    
    public var data: Data {
        
        fatalError()
    }
}

