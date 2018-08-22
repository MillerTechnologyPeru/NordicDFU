//
//  DFUStreamZip.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/17/18.
//

import Foundation
import Bluetooth
import ZIPFoundation

#if swift(>=3.2)
#elseif swift(>=3.0)
    import Codable
#endif

public final class DFUStreamZip {
    
    internal static let jsonDecoder = JSONDecoder()
    
    public let manifest: DFUManifest
    
    public let firmware: DFUFirmware
    
    public convenience init(url: URL) throws {
        
        guard let archive = Archive(url: url, accessMode: .read)
            else { throw DFUStreamZipError.invalidFormat }
        
        try self.init(archive: archive)
    }
    
    private init(archive: Archive) throws {
        
        guard let manifestEntry = archive[File.manifest.rawValue]
            else { throw DFUStreamZipError.noManifest }
        
        var manifestData = Data()
        guard let _ = try? archive.extract(manifestEntry, consumer: { manifestData.append($0) })
            else { throw DFUStreamZipError.invalidFormat }
        
        let jsonDecoder = DFUStreamZip.jsonDecoder
        
        guard let manifest = try? jsonDecoder.decode(DFUManifest.self, from: manifestData)
            else { throw DFUStreamZipError.invalidManifest }
        
        self.manifest = manifest
        
        switch manifest.manifest {
            
        case let .softdeviceBootloader(manifestInfo):
            
            let systemData = try DFUStreamZip.load(manifestInfo.softdeviceBootloader, type: [.softdevice, .bootloader], from: archive)
            
            var firmwareData = [systemData]
            
            if let applicationManifest = manifestInfo.application {
                
                let applicationData = try DFUStreamZip.load(applicationManifest, type: [.application], from: archive)
                
                firmwareData.append(applicationData)
            }
            
            self.firmware = DFUFirmware(data: firmwareData)
            
        case let .softdevice(manifestInfo):
            
            let systemData = try DFUStreamZip.load(manifestInfo.softdevice, type: [.softdevice], from: archive)
            
            var firmwareData = [systemData]
            
            if let applicationManifest = manifestInfo.application {
                
                let applicationData = try DFUStreamZip.load(applicationManifest, type: [.application], from: archive)
                
                firmwareData.append(applicationData)
            }
            
            self.firmware = DFUFirmware(data: firmwareData)
            
        case let .bootloader(manifestInfo):
            
            let systemData = try DFUStreamZip.load(manifestInfo.bootloader, type: [.bootloader], from: archive)
            
            var firmwareData = [systemData]
            
            if let applicationManifest = manifestInfo.application {
                
                let applicationData = try DFUStreamZip.load(applicationManifest, type: [.application], from: archive)
                
                firmwareData.append(applicationData)
            }
            
            self.firmware = DFUFirmware(data: firmwareData)
            
        case let .application(manifestInfo):
            
            let applicationData = try DFUStreamZip.load(manifestInfo.application, type: [.application], from: archive)
            
            self.firmware = DFUFirmware(data: [applicationData])
        }
    }
    
    private static func load <T> (_ firmwareInfo: T,
                             type: BitMaskOptionSet<DFUFirmwareType>,
                             from archive: Archive) throws -> DFUFirmware.FirmwareData where T: DFUManifestFirmwareInfoProtocol {
        
        let bin = try archive.load(path: firmwareInfo.binFile)
        
        let dat: Data?
        
        if let datFile = firmwareInfo.datFile {
            
            dat = try archive.load(path: datFile)
            
        } else {
            
            dat = nil
        }
        
        return DFUFirmware.FirmwareData(type: type, data: bin, initPacket: dat)
    }
}

internal extension DFUStreamZip {
    
    enum File: String {
        
        case manifest = "manifest.json"
    }
}

internal extension DFUStreamZip {
    
    struct ManifestFirmwareData {
        
        let bin: Data
        let dat: Data?
    }
}

internal extension Archive {
    
    subscript (file: DFUStreamZip.File) -> Entry? {
        
        let path = file.rawValue
        
        return self[path]
    }
    
    func load(path: String) throws -> Data {
        
        guard let entry = self[path]
            else { throw DFUStreamZipError.fileNotFound }
        
        var data = Data()
        guard let _ = try? self.extract(entry, consumer: { data.append($0) })
            else { throw DFUStreamZipError.invalidFormat }
        
        return data
    }
}
