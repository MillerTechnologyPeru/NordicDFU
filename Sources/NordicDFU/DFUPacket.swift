//
//  DFUPacket.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/7/18.
//

import Foundation
import Bluetooth

/// DFU Packet
public struct DFUPacket: GATTProfileCharacteristic {
    
    public static let uuid = BluetoothUUID(rawValue: "00001534-1212-EFDE-1523-785FEABCD123")!
    
    public static let service: GATTProfileService.Type = DFUService.self
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.writeWithoutResponse]
    
    internal let packetSize: UInt32 = 20 // Legacy DFU does not support higher MTUs
    
    /// Number of bytes of firmware already sent.
    public let bytesSent: UInt32
    
    /// Number of bytes sent at the last progress notification. This value is used to calculate the current speed.
    public let bytesSentSinceProgessNotification: UInt32
    
    public init?(data: Data) {
        
        fatalError()
    }
    
    public var data: Data {
        
        fatalError()
    }
}
