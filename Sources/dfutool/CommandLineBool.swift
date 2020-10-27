//
//  CommandLineBool.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/31/18.
//

/// Boolean for use with command line arguments.
public enum CommandLineBool: String {
    
    case `true` = "true"
    case `false` = "false"
}

public extension CommandLineBool {
    
    init(_ boolValue: Bool) {
        
        if boolValue {
            self = .true
        } else {
            self = .false
        }
    }
    
    var boolValue: Bool {
        switch self {
        case .true: return true
        case .false: return false
        }
    }
}

extension CommandLineBool: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral boolValue: Bool) {
        self.init(boolValue)
    }
}
