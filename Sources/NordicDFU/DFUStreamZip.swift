//
//  DFUStreamZip.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/17/18.
//

import Foundation
import Bluetooth
import ZIPFoundation

internal final class DFUStreamZip {
    
    internal static let jsonDecoder = JSONDecoder()
    
    let manifest: DFUManifest
    
    init(url: URL, type: BitMaskOptionSet<DFUFirmwareType>) throws {
        
        guard let archive = Archive(url: url, accessMode: .read)
            else { throw DFUStreamZipError.invalidFormat }
        
        guard let manifestEntry = archive[File.manifest.rawValue]
            else { throw DFUStreamZipError.noManifest }
        
        
        var manifestData = Data()
        guard let _ = try? archive.extract(manifestEntry, consumer: { manifestData.append($0) })
            else { throw DFUStreamZipError.invalidFormat }
        
        let jsonDecoder = DFUStreamZip.jsonDecoder
        
        guard let manifest = try? jsonDecoder.decode(DFUManifest.self, from: manifestData)
            else { throw DFUStreamZipError.invalidManifest }
        
        self.manifest = manifest
    }
}

internal extension DFUStreamZip {
    
    enum File: String {
        
        case manifest = "manifest.json"
    }
}

internal extension Archive {
    
    subscript (file: DFUStreamZip.File) -> Entry? {
        
        let path = "/" + file.rawValue
        
        return self[path]
    }
}
