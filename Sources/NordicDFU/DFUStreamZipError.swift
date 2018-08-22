//
//  DFUStreamZipError.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/17/18.
//

import Foundation

/// DFU Stream Zip Error
public enum DFUStreamZipError: Error {

    case invalidFormat
    case noManifest
    case invalidManifest
    case fileNotFound
    case typeNotFound
}

// MARK: - CustomNSError

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

extension DFUStreamZipError: CustomNSError {
    
    /// The domain of the error.
    public static var errorDomain: String { return "com.nordicsemiconductor.NordicDFU.DFUStreamZipError" }
    
    /// The error code within the given domain.
    //public var errorCode: Int
    
    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        
        var userInfo = [String: Any](minimumCapacity: 1)
        
        let description: String
        
        switch self {
            
        case .invalidFormat:
            
            description = String(format: NSLocalizedString(
                "Invalid file format.",
                comment: "com.nordicsemiconductor.NordicDFU.DFUStreamZipError.invalidFormat"))
            
        case .noManifest:
            
            description = String(format: NSLocalizedString(
                "No manifest file found.",
                comment: "com.nordicsemiconductor.NordicDFU.DFUStreamZipError.noManifest"))
            
        case .invalidManifest:
            
            description = String(format: NSLocalizedString(
                "Invalid manifest.json file.",
                comment: "com.nordicsemiconductor.NordicDFU.DFUStreamZipError.invalidManifest")
            )
            
        case .fileNotFound:
            
            description = String(format: NSLocalizedString(
                "File specified in manifest.json not found in ZIP.",
                comment: "com.nordicsemiconductor.NordicDFU.DFUStreamZipError.fileNotFound")
            )
            
        case .typeNotFound:
            
            description = String(format: NSLocalizedString(
                "Specified type not found in manifest.json.",
                comment: "com.nordicsemiconductor.NordicDFU.DFUStreamZipError.typeNotFound")
            )
        }
        
        userInfo[NSLocalizedDescriptionKey] = description
        
        return userInfo
    }
}

#endif
