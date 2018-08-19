//
//  SoftdeviceBootloaderInfo.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/19/18.
//
//

import Foundation

#if swift(>=3.2)
#elseif swift(>=3.0)
    import Codable
#endif

///
public struct DFUSoftdeviceBootloaderInfo {
    
    public var bootloaderSize: UInt32?
    
    public var softdeviceSize: UInt32?
}

// MARK: - Codable

extension DFUSoftdeviceBootloaderInfo: Codable {
    
    public enum CodingKeys: String, CodingKey {
        
        case bootloaderSize = "bl_size"
        case softdeviceSize = "sd_size"
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.bootloaderSize = try container.decodeIfPresent(UInt32.self, forKey: .bootloaderSize)
        self.softdeviceSize = try container.decodeIfPresent(UInt32.self, forKey: .softdeviceSize)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(bootloaderSize, forKey: .bootloaderSize)
        try container.encode(softdeviceSize, forKey: .softdeviceSize)
    }
}
