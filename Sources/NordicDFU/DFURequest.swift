//
//  DFURequest.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation

public protocol DFUMessage {
    
    /// DFU Opcode
    static var opcode: DFUOpcode { get }
    
    /// Initialize from PDU bytes.
    init?(data: Data)
    
    /// Request PDU data.
    var data: Data { get }
}

/// DFU Request
public protocol DFURequest: DFUMessage {
    
    /// Whether the request expects acknowledgement from the peripheral.
    static var acknowledge: Bool { get }
}

// Default values
public extension DFURequest {
    
    static var acknowledge: Bool {
        
        return true
    }
    
    var data: Data {
        
        return Data([type(of: self).opcode.rawValue])
    }
}

// MARK: - Requests

/// Start DFU
public struct DFUStartRequest: DFURequest {
    
    public static let opcode: DFUOpcode = .start
    
    public static let acknowledge = false
    
    internal static let length = MemoryLayout<DFUOpcode.RawValue>.size + MemoryLayout<FirmwareType.RawValue>.size
    
    public var firmwareType: FirmwareType
    
    public init(firmwareType: FirmwareType) {
        
        self.firmwareType = firmwareType
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
        
        guard let firmwareType = FirmwareType(rawValue: data[1])
            else { return nil }
        
        self.firmwareType = firmwareType
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue, firmwareType.rawValue])
    }
}

/// Start DFU Version 1
public struct DFUStartRequestV1: DFURequest {
    
    public static let opcode: DFUOpcode = .start
    
    internal static let length = MemoryLayout<DFUOpcode.RawValue>.size
    
    public init() { }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
    }
}

/// Initialize DFU Parameters
public enum DFUInitialize: UInt8, DFURequest {
    
    public static let opcode: DFUOpcode = .initialize
    
    internal static let length = 2
    
    case receiveInitPacket  = 0
    case initPacketComplete = 1
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
        
        self.init(rawValue: data[1])
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue, rawValue])
    }
}

/// Initialize DFU Parameters Version 1
public struct DFUInitializeV1: DFURequest {
    
    public static let opcode: DFUOpcode = .initialize
    
    public init() { }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).opcode.rawValue,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
    }
}

/// Receive Firmware Image
public struct DFUReceiveFirmwareImage: DFURequest {
    
    public static let opcode: DFUOpcode = .receiveFirmwareImage
    
    public init() { }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).opcode.rawValue,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
    }
}

/// DFU Validate Firmware
public struct DFUValidateFirmware: DFURequest {
    
    public static let opcode: DFUOpcode = .validateFirmware
    
    public init() { }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).opcode.rawValue,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
    }
}

/// DFU Activate and Reset
public struct DFUActivate: DFURequest {
    
    public static let opcode: DFUOpcode = .activate
    
    public static let acknowledge = false
    
    public init() { }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).opcode.rawValue,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
    }
}

/// DFU Reset
public struct DFUReset: DFURequest {
    
    public static let opcode: DFUOpcode = .reset
    
    public static let acknowledge = false
    
    public init() { }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).opcode.rawValue,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
    }
}

/// DFU Receipt Notification Request
public struct DFUPacketReceiptRequest: DFURequest {
    
    public static let opcode: DFUOpcode = .packetReceipt
    
    internal static let length = 3
    
    /// Number of packets of firmware data to be received by the DFU target
    /// before sending a new Packet Receipt Notification.
    ///
    /// Set `0` to disable PRNs (not recommended).
    public var packets: UInt16
    
    public init(packets: UInt16 = 0) {
        
        self.packets = packets
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length,
            let opcode = DFUOpcode(rawValue: data[0]),
            opcode == type(of: self).opcode
            else { return nil }
        
        self.packets = UInt16(littleEndian: UInt16(bytes: (data[1], data[2])))
    }
    
    public var data: Data {
        
        let packetBytes = packets.littleEndian.bytes
        
        return Data([type(of: self).opcode.rawValue, packetBytes.0, packetBytes.1])
    }
}
