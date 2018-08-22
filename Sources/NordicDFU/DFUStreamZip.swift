//
//  DFUStreamZip.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/17/18.
//

import Foundation
import ZIPFoundation

internal final class DFUStreamZip {
    
    internal static let jsonDecoder = JSONDecoder()
    
    let manifest: DFUManifest
    
    convenience init(url: URL) throws {
        
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
            
            fatalError()
            
        case let .softdevice(manifestInfo):
            
            fatalError()
            
        case let .bootloader(manifestInfo):
            
            fatalError()
            
        case let .application(manifestInfo):
            
            let firmwareData = try DFUStreamZip.load(manifestInfo.application, from: archive)
            
            dump(firmwareData)
            
        }
    }
    
    private static func load(_ firmwareInfo: DFUManifestFirmwareInfo,
                             from archive: Archive) throws -> ManifestFirmwareData {
        
        let bin = try archive.load(path: firmwareInfo.binFile)
        
        let dat: Data?
        
        if let datFile = firmwareInfo.datFile {
            
            dat = try archive.load(path: datFile)
            
        } else {
            
            dat = nil
        }
        
        return ManifestFirmwareData(bin: bin, dat: dat)
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
