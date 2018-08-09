//
//  DFUFirmwareSize.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/8/18.
//

import Foundation

/// DFU Firmware Size
public struct DFUFirmwareSize {
    
    /// Size of the softdevice in bytes.
    ///
    /// If not even, add it to the bootloader size to get size of `softdevice_bootloader.bin`.
    public var softdevice: UInt32
    
    /// Size of the bootloader in bytes.
    ///
    /// - Note: If equal to 1 the ZIP contains SD+BL and size of SD or BL is not known exactly, but their sum is known.
    public var bootloader: UInt32
    
    /// Size of the application in bytes.
    public var application: UInt32
    
    public init(softdevice: UInt32,
                bootloader: UInt32,
                application: UInt32) {
        
        self.softdevice = softdevice
        self.bootloader = bootloader
        self.application = application
    }
}

extension DFUFirmwareSize: DFUPacketValue {
    
    internal static let length = MemoryLayout<UInt32>.size * 3
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length
            else { return nil }
        
        self.softdevice = UInt32(littleEndian: UInt32(bytes: (data[0], data[1], data[2], data[3])))
        self.bootloader = UInt32(littleEndian: UInt32(bytes: (data[4], data[5], data[6], data[7])))
        self.application = UInt32(littleEndian: UInt32(bytes: (data[8], data[9], data[10], data[11])))
    }
    
    public var data: Data {
        
        let softdeviceBytes = softdevice.littleEndian.bytes
        let bootloaderBytes = bootloader.littleEndian.bytes
        let applicationBytes = application.littleEndian.bytes
        
        return Data([
            softdeviceBytes.0,
            softdeviceBytes.1,
            softdeviceBytes.2,
            softdeviceBytes.3,
            bootloaderBytes.0,
            bootloaderBytes.1,
            bootloaderBytes.2,
            bootloaderBytes.3,
            applicationBytes.0,
            applicationBytes.1,
            applicationBytes.2,
            applicationBytes.3,
            ])
    }
}
