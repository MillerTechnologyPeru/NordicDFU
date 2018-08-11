//
//  SecureDFUPacket.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

import Foundation
import Bluetooth

public struct SecureDFUPacket: GATTProfileCharacteristic {
    
    public static let uuid = BluetoothUUID(rawValue: "8EC90002-F315-4F60-9FB8-838830DAEA50")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.writeWithoutResponse]
    
    public static var service: GATTProfileService.Type = SecureDFUService.self
    
    public init?(data: Data) {
        
        fatalError()
    }
    
    public var data: Data {
        
        fatalError()
    }
}
