//
//  SecureDFUExtendedErrorCode.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

/// Secure DFU Extended Error Code
public enum SecureDFUExtendedError: UInt8, Error {
    
    case noError              = 0x00
    case wrongCommandFormat   = 0x02
    case unknownCommand       = 0x03
    case initCommandInvalid   = 0x04
    case fwVersionFailure     = 0x05
    case hwVersionFailure     = 0x06
    case sdVersionFailure     = 0x07
    case signatureMissing     = 0x08
    case wrongHashType        = 0x09
    case hashFailed           = 0x0A
    case wrongSignatureType   = 0x0B
    case verificationFailed   = 0x0C
    case insufficientSpace    = 0x0D
}

// MARK: - CustomStringConvertible

extension SecureDFUExtendedError: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .noError:              return "No error"
        case .wrongCommandFormat:   return "Wrong command format"
        case .unknownCommand:       return "Unknown command"
        case .initCommandInvalid:   return "Init command was invalid"
        case .fwVersionFailure:     return "FW version check failed"
        case .hwVersionFailure:     return "HW version check failed"
        case .sdVersionFailure:     return "SD version check failed"
        case .signatureMissing:     return "Signature missing"
        case .wrongHashType:        return "Invalid hash type"
        case .hashFailed:           return "Hashing failed"
        case .wrongSignatureType:   return "Invalid signature type"
        case .verificationFailed:   return "Verification failed"
        case .insufficientSpace:    return "Insufficient space for upgrade"
        }
    }
}
