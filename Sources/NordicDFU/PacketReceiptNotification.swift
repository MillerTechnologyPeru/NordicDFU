//
//  PacketReceiptNotification.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation

/// DFU Packet Receipt Notification
public struct DFUPacketReceiptNotification: DFUResponseProtocol {
    
    public static let opcode: DFUOpcode = .packetReceiptNotification
    
    internal static let length = MemoryLayout<DFUOpcode.RawValue>.size + MemoryLayout<UInt32>.size
    
    /// Bytes recieved.
    public let bytesReceived: UInt32
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
        
        self.bytesReceived = UInt32(littleEndian: UInt32(bytes: (data[1], data[2], data[3], data[4])))
    }
}
