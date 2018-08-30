//
//  ButtonlessDFUResultCode.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/30/18.
//

public enum ButtonlessDFUResultCode: UInt8 {
    
    case success            = 0x01
    case opCodeNotSupported = 0x02
    case operationFailed    = 0x04
}

// MARK: - CustomStringConvertible

extension ButtonlessDFUResultCode: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .success:            return "Success"
        case .opCodeNotSupported: return "Operation not supported"
        case .operationFailed:    return "Operation failed"
        }
    }
}

// MARK: - Error

public enum ButtonlessDFUError: UInt8, Error {
    
    case opCodeNotSupported = 0x02
    case operationFailed    = 0x04
}

public extension ButtonlessDFUError {
    
    init?(code: ButtonlessDFUResultCode) {
        
        self.init(rawValue: code.rawValue)
    }
    
    var code: ButtonlessDFUResultCode {
        
        return ButtonlessDFUResultCode(rawValue: rawValue)!
    }
}

extension ButtonlessDFUError: CustomStringConvertible {
    
    public var description: String {
        
        return code.description
    }
}
