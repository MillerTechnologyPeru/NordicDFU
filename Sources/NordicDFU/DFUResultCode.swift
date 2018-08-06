//
//  DFUResultCode.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

/// DFU Result Code
public enum DFUResultCode: UInt8 {
    
    case success              = 1
    case invalidState         = 2
    case notSupported         = 3
    case dataSizeExceedsLimit = 4
    case crcError             = 5
    case operationFailed      = 6
}

// MARK: - CustomStringConvertible

extension DFUResultCode: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case .success:              return "Success"
        case .invalidState:         return "Device is in invalid state"
        case .notSupported:         return "Operation not supported"
        case .dataSizeExceedsLimit: return "Data size exceeds limit"
        case .crcError:             return "CRC Error"
        case .operationFailed:      return "Operation failed"
        }
    }
}

// MARK: - Error

/// DFU Error
public enum DFUError: UInt8, Error {
    
    case invalidState         = 2
    case notSupported         = 3
    case dataSizeExceedsLimit = 4
    case crcError             = 5
    case operationFailed      = 6
}

public extension DFUError {
    
    init?(code: DFUResultCode) {
        
        self.init(rawValue: code.rawValue)
    }
    
    var code: DFUResultCode {
        
        return DFUResultCode(rawValue: rawValue)!
    }
}

extension DFUError: CustomStringConvertible {
    
    public var description: String {
        
        return code.description
    }
}
