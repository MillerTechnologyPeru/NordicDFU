//
//  GATTProfile.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation
import Bluetooth
import GATT

/// GATT Profile
public protocol GATTProfile {
    
    static var services: [GATTProfileService.Type] { get }
}

/// GATT Service
public protocol GATTProfileService {
    
    static var uuid: BluetoothUUID { get }
    
    static var isPrimary: Bool { get }
    
    static var characteristics: [GATTProfileCharacteristic.Type] { get }
}

/// GATT Service Characteristic
public protocol GATTProfileCharacteristic {
    
    static var service: GATTProfileService.Type { get }
    
    static var uuid: BluetoothUUID { get }
        
    init?(data: Data)
    
    var data: Data { get }
}
