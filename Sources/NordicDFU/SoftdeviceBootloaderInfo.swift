//
//  SoftdeviceBootloaderInfo.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/19/18.
//
//

import Foundation

/// Nordic DFU Softdevice Bootloader Information
public struct DFUSoftdeviceBootloaderInfo: DFUManifestFirmwareInfoProtocol, Codable, Equatable {
    
    internal enum CodingKeys: String, CodingKey {
        
        case binFile = "bin_file"
        case datFile = "dat_file"
        case bootloaderSize = "bl_size"
        case softdeviceSize = "sd_size"
    }
    
    public var binFile: String
    
    public var datFile: String?
    
    public var bootloaderSize: UInt32?
    
    public var softdeviceSize: UInt32?
}
