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
    
    case softdevice(DFUManifestSoftdeviceInfo)
    case bootloader(DFUManifestBootloaderInfo)
    case softdeviceBootloader(DFUManifestSoftdeviceBootloaderInfo)
    case application(DFUManifestApplicationInfo)
}

public extension DFUManifestInfo {
    
    public var application: DFUManifestFirmwareInfo? {
        
        switch self {
        case let .softdevice(value): return value.application
        case let .bootloader(value): return value.application
        case let .softdeviceBootloader(value): return value.application
        case let .application(value): return value.application
        }
    }
    
    public var version: DFUVersion? {
        
        switch self {
        case let .softdevice(value): return value.version
        case let .bootloader(value): return value.version
        case let .softdeviceBootloader(value): return value.version
        case let .application(value): return value.version
        }
    }
}

public struct DFUManifestSoftdeviceInfo {
        
    public let softdevice: DFUManifestFirmwareInfo
    
    public let application: DFUManifestFirmwareInfo?
    
    public let version: DFUVersion?
}

public struct DFUManifestBootloaderInfo {
    
    public let bootloader: DFUManifestFirmwareInfo
    
    public let application: DFUManifestFirmwareInfo?
    
    public let version: DFUVersion?
}

public struct DFUManifestSoftdeviceBootloaderInfo {
    
    public let softdeviceBootloader: DFUSoftdeviceBootloaderInfo
    
    public let application: DFUManifestFirmwareInfo?
    
    public let version: DFUVersion?
}

public struct DFUManifestApplicationInfo {
    
    public let application: DFUManifestFirmwareInfo
    
    public let version: DFUVersion?
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
        case version = "dfu_version"
    }
    
    public init(from decoder: Decoder) throws {
        
        // The manifest.json file may specify only:
        // 1. a softdevice, a bootloader, or both combined (with, or without an app)
        // 2. only the app
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let version = try container.decodeIfPresent(DFUVersion.self, forKey: .version)
        
        if let softdevice = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .softdevice) {
            
            let application = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .application)
            
            let info = DFUManifestSoftdeviceInfo(softdevice: softdevice,
                                                 application: application,
                                                 version: version)
            
            self = .softdevice(info)
            
        } else if let bootloader = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .bootloader) {
            
            let application = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .application)
            
            let info = DFUManifestBootloaderInfo(bootloader: bootloader,
                                                 application: application,
                                                 version: version)
            
            self = .bootloader(info)
            
        } else if let softdeviceBootloader = try container.decodeIfPresent(DFUSoftdeviceBootloaderInfo.self, forKey: .softdeviceBootloader) {
            
            let application = try container.decodeIfPresent(DFUManifestFirmwareInfo.self, forKey: .application)
            
            let info = DFUManifestSoftdeviceBootloaderInfo(softdeviceBootloader: softdeviceBootloader,
                                                           application: application,
                                                           version: version)
            
            self = .softdeviceBootloader(info)
            
        } else {
            
            // must have application
            let application = try container.decode(DFUManifestFirmwareInfo.self, forKey: .application)
            
            let info = DFUManifestApplicationInfo(application: application, version: version)
            
            self = .application(info)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            
        case let .softdevice(value):
            
            try container.encode(value.softdevice, forKey: .softdevice)
            try container.encode(value.application, forKey: .application)
            try container.encode(value.version, forKey: .version)
            
        case let .bootloader(value):
            
            try container.encode(value.bootloader, forKey: .bootloader)
            try container.encode(value.application, forKey: .application)
            try container.encode(value.version, forKey: .version)
            
        case let .softdeviceBootloader(value):
            
            try container.encode(value.softdeviceBootloader, forKey: .softdeviceBootloader)
            try container.encode(value.application, forKey: .application)
            try container.encode(value.version, forKey: .version)
            
        case let .application(value):
            
            try container.encode(value.application, forKey: .application)
            try container.encode(value.version, forKey: .version)
        }
    }
}
