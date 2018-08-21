//
//  Manifest.swift
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

/// DFU Manifest
public struct DFUManifest {
    
    public let manifest: DFUManifestInfo
    
    public init(manifest: DFUManifestInfo) {
        
        self.manifest = manifest
    }
}

/// DFU Manifest
///
/// The manifest.json file may specify only:
/// 1. a softdevice, a bootloader, or both combined (with, or without an app)
/// 2. only the app
public enum DFUManifestInfo {
    
    case softdevice(DFUManifestFirmwareInfo, application: DFUManifestFirmwareInfo?)
    case bootloader(DFUManifestFirmwareInfo, application: DFUManifestFirmwareInfo?)
    case softdeviceBootloader(DFUSoftdeviceBootloaderInfo, application: DFUManifestFirmwareInfo?)
    case application(DFUManifestFirmwareInfo)
}

public extension DFUManifestInfo {
    
    public var application: DFUManifestFirmwareInfo? {
        
        switch self {
        case let .softdevice(_, application: application): return application
        case let .bootloader(_, application: application): return application
        case let .softdeviceBootloader(_, application: application): return application
        case let .application(application): return application
        }
    }
}

// MARK: - Codable

extension DFUManifest: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        
        case manifest
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.manifest = try container.decode(DFUManifestInfo.self, forKey: .manifest)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(manifest, forKey: .manifest)
    }
}

extension DFUManifestInfo: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        
        case application
        case softdeviceBootloader = "softdevice_bootloader"
        case softdevice
        case bootloader
    }
    
    public init(from decoder: Decoder) throws {
        
        // The manifest.json file may specify only:
        // 1. a softdevice, a bootloader, or both combined (with, or without an app)
        // 2. only the app
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let softdevice = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .softdevice) {
            
            let application = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .application)
            
            self = .softdevice(softdevice, application: application)
            
        } else if let bootloader = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .bootloader) {
            
            let application = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .application)
            
            self = .bootloader(bootloader, application: application)
            
        } else if let softdeviceBootloader = try container.decodeIfPresent(DFUSoftdeviceBootloaderInfo.self, forKey: .softdeviceBootloader) {
            
            let application = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .application)
            
            self = .softdeviceBootloader(softdeviceBootloader, application: application)
            
        } else {
            
            // must have application
            let application = try container.decode(DFUManifestFirmwareInfo.self, forKey: .application)
            
            self = .application(application)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .softdevice(softdevice, application: application):
            
            try container.encode(softdevice, forKey: .softdevice)
            try container.encode(application, forKey: .application)
            
        case let .bootloader(bootloader, application: application):
            
            try container.encode(bootloader, forKey: .bootloader)
            try container.encode(application, forKey: .application)
            
        case let .softdeviceBootloader(softdeviceBootloader, application: application):
            
            try container.encode(softdeviceBootloader, forKey: .softdeviceBootloader)
            try container.encode(application, forKey: .application)
            
        case let .application(application):
            
            try container.encode(application, forKey: .application)
        }
    }
}
