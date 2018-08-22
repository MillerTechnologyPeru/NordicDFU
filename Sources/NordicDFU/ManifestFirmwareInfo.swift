//
//  ManifestFirmwareInfo.swift
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

/// DFU Manifest Firmware Info
public struct DFUManifestFirmwareInfo: DFUManifestFirmwareInfoProtocol {
    
    public var binFile: String
    
    public var datFile: String?
}

public protocol DFUManifestFirmwareInfoProtocol {
    
    var binFile: String { get }
    
    var datFile: String? { get }
}

// MARK: - Codable

extension DFUManifestFirmwareInfo: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        
        case binFile = "bin_file"
        case datFile = "dat_file"
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.binFile = try container.decode(String.self, forKey: .binFile)
        self.datFile = try container.decodeIfPresent(String.self, forKey: .datFile)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(binFile, forKey: .binFile)
        try container.encode(datFile, forKey: .datFile)
    }
}
