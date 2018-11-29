//
//  SoftdeviceBootloaderInfo.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/19/18.
//
//

import Foundation

/// Nordic DFU Softdevice Bootloader Information
public struct DFUSoftdeviceBootloaderInfo: DFUManifestFirmwareInfoProtocol {
    
    public var binFile: String
    
    public var datFile: String?
    
    public var bootloaderSize: UInt32?
    
    public var softdeviceSize: UInt32?
}

// MARK: - Codable

extension DFUSoftdeviceBootloaderInfo: Codable {
    
    public enum CodingKeys: String, CodingKey {
        
        case binFile = "bin_file"
        case datFile = "dat_file"
        case bootloaderSize = "bl_size"
        case softdeviceSize = "sd_size"
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.binFile = try container.decode(String.self, forKey: .binFile)
        self.datFile = try container.decodeIfPresent(String.self, forKey: .datFile)
        
        self.bootloaderSize = try container.decodeIfPresent(UInt32.self, forKey: .bootloaderSize)
        self.softdeviceSize = try container.decodeIfPresent(UInt32.self, forKey: .softdeviceSize)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(binFile, forKey: .binFile)
        try container.encode(datFile, forKey: .datFile)
        
        try container.encode(bootloaderSize, forKey: .bootloaderSize)
        try container.encode(softdeviceSize, forKey: .softdeviceSize)
    }
}
