//
//  DFUPacket.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/7/18.
//

import Foundation
import Bluetooth

/// DFU Packet
public struct DFUPacket <Value: DFUPacketValue>: GATTProfileCharacteristic {
    
    public static var uuid: BluetoothUUID { return BluetoothUUID(rawValue: "00001534-1212-EFDE-1523-785FEABCD123")! }
    
    public static var service: GATTProfileService.Type { return DFUService.self }
    
    public static var properies: BitMaskOptionSet<GATT.Characteristic.Property> { return [.writeWithoutResponse] }
    
    internal let packetSize: UInt32 = 20 // Legacy DFU does not support higher MTUs
    
    public let value: Value
    
    public init(value: Value) {
        
        self.value = value
    }
    
    public init?(data: Data) {
        
        guard let value = Value(data: data)
            else { return nil }
        
        self.init(value: value)
    }
    
    public var data: Data {
        
        return value.data
    }
}

public protocol DFUPacketValue {
    
    init?(data: Data)
    
    var data: Data { get }
}

public struct DFUPacketData: DFUPacketValue {
    
    public let data: Data
    
    public init(data: Data) {
        
        self.data = data
    }
}
