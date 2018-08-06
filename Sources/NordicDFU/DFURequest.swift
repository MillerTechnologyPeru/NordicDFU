//
//  DFURequest.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation


/// DFU Request
public protocol DFURequest {
    
    /// Request Opcode
    static var opcode: DFUOpcode { get }
    
    /// Request PDU data.
    var data: Data { get }
}

public extension DFURequest {
    
    var data: Data {
        
        return Data([type(of: self).opcode.rawValue])
    }
}

/// Start DFU
public struct DFUStartRequest: DFURequest {
    
    public static let opcode: DFUOpcode = .start
    
    public var firmwareType: FirmwareType
    
    public init(firmwareType: FirmwareType) {
        
        self.firmwareType = firmwareType
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue, firmwareType.rawValue])
    }
}

/// Start DFU Version 1
public struct DFUStartRequestV1: DFURequest {
    
    public static let opcode: DFUOpcode = .start
    
    public init() { }
}

/// Initialize DFU Parameters
public struct DFUInitialize: DFURequest {
    
    public static let opcode: DFUOpcode = .initialize
    
    public var parameter: DFUInitializeParameter
    
    public init(parameter: DFUInitializeParameter) {
        
        self.parameter = parameter
    }
    
    public var data: Data {
        
        return Data([type(of: self).opcode.rawValue, parameter.rawValue])
    }
}

/// Initialize DFU Parameters Version 1
public struct DFUInitializeV1: DFURequest {
    
    public static let opcode: DFUOpcode = .initialize
    
    public init() { }
}

/// Receive Firmware Image
public struct DFUReceiveFirmwareImage: DFURequest {
    
    public static let opcode: DFUOpcode = .receiveFirmwareImage
    
    public init() { }
}

/// DFU Validate Firmware
public struct DFUValidateFirmware: DFURequest {
    
    public static let opcode: DFUOpcode = .validateFirmware
    
    public init() { }
}

/// DFU Activate and Reset
public struct DFUActivate: DFURequest {
    
    public static let opcode: DFUOpcode = .activate
    
    public init() { }
}

/// DFU Reset
public struct DFUReset: DFURequest {
    
    public static let opcode: DFUOpcode = .reset
    
    public init() { }
}

/// DFU Receipt Notification Request
public struct DFUPacketReceiptNotificationRequest: DFURequest {
    
    public static let opcode: DFUOpcode = .packetReceipt
    
    /// Number of packets of firmware data to be received by the DFU target
    /// before sending a new Packet Receipt Notification.
    ///
    /// Set `0` to disable PRNs (not recommended).
    public var packets: UInt16
    
    public init(packets: UInt16 = 0) {
        
        self.packets = packets
    }
    
    public var data: Data {
        
        let packetBytes = packets.littleEndian.bytes
        
        return Data([type(of: self).opcode.rawValue, packetBytes.0, packetBytes.1])
    }
}
