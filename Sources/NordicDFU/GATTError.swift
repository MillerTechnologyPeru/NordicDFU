//
//  Error.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation
import Bluetooth

/// Nordic GATT Error
public enum NordicGATTError: Error {
    
    /// Invalid data.
    case invalidData(Data?)
    
    case invalidChecksum(UInt32, expected: UInt32)
}

internal typealias GATTError = NordicGATTError

// MARK: - CustomNSError

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
/*
extension NordicGATTError: CustomNSError {
    
    public enum UserInfoKey: String {
        
        /// Bluetooth UUID value (for characteristic or service).
        case uuid = "com.nordicsemiconductor.NordicDFU.NordicGATTError.BluetoothUUID"
        
        /// Data
        case data = "com.nordicsemiconductor.NordicDFU.NordicGATTError.Data"
    }
    
    /// The domain of the error.
    public static var errorDomain: String { return "com.nordicsemiconductor.NordicDFU.NordicGATTError" }
    
    /// The error code within the given domain.
    //public var errorCode: Int
    
    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        
        var userInfo = [String : Any](minimumCapacity: 2)
        
        switch self {
            
        case let .invalidData(data):
            
            let description = String(format: NSLocalizedString("Invalid data.", comment: "com.nordicsemiconductor.NordicDFU.NordicGATTError.invalidData"))
            
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo[UserInfoKey.data.rawValue] = data
        }
        
        return userInfo
    }
}
*/
#endif
