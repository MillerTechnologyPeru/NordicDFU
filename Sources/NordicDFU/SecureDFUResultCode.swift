//
//  SecureDFUResultCode.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

///
public enum SecureDFUResultCode: UInt8 {
    
    // Invalid code
    case invalidCode           = 0x00
    case success               = 0x01
    case opCodeNotSupported    = 0x02
    case invalidParameter      = 0x03
    case insufficientResources = 0x04
    case invalidObject         = 0x05
    case signatureMismatch     = 0x06
    case unsupportedType       = 0x07
    case operationNotpermitted = 0x08
    case operationFailed       = 0x0A
    case extendedError         = 0x0B
}

// MARK: - CustomStringConvertible

extension SecureDFUResultCode: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case .invalidCode:           return "Invalid code"
        case .success:               return "Success"
        case .opCodeNotSupported:    return "Operation not supported"
        case .invalidParameter:      return "Invalid parameter"
        case .insufficientResources: return "Insufficient resources"
        case .invalidObject:         return "Invalid object"
        case .signatureMismatch:     return "Signature mismatch"
        case .operationNotpermitted: return "Operation not permitted"
        case .unsupportedType:       return "Unsupported type"
        case .operationFailed:       return "Operation failed"
        case .extendedError:         return "Extended error"
        }
    }
}

public enum SecureDFUError: UInt8, Error {
    
    // Invalid code
    case invalidCode           = 0x00
    case opCodeNotSupported    = 0x02
    case invalidParameter      = 0x03
    case insufficientResources = 0x04
    case invalidObject         = 0x05
    case signatureMismatch     = 0x06
    case unsupportedType       = 0x07
    case operationNotpermitted = 0x08
    case operationFailed       = 0x0A
    case extendedError         = 0x0B
}

public extension SecureDFUError {
    
    init?(code: SecureDFUResultCode) {
        
        self.init(rawValue: code.rawValue)
    }
    
    var code: SecureDFUResultCode {
        
        return SecureDFUResultCode(rawValue: rawValue)!
    }
}

extension SecureDFUError: CustomStringConvertible {
    
    public var description: String {
        
        return code.description
    }
}
