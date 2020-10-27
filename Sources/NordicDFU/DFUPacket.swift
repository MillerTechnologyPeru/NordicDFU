//
//  DFUPacket.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/7/18.
//

import Foundation
import Bluetooth
import GATT

/// DFU Packet
public struct DFUPacket: GATTProfileCharacteristic {
    
    public static let uuid: BluetoothUUID = BluetoothUUID(rawValue: "00001534-1212-EFDE-1523-785FEABCD123")!
    
    public static let service: GATTProfileService.Type = DFUService.self
    
    public static let properties: BitMaskOptionSet<GATT.CharacteristicProperty> = [.writeWithoutResponse]
    
    internal let packetSize: UInt32 = 20 // Legacy DFU does not support higher MTUs
    
    public let data: Data
    
    public init?(data: Data) {
        
        self.data = data
    }
}
