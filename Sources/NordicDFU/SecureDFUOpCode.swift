//
//  SecureDFUOpCode.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

public enum SecureDFUOpcode: UInt8 {
    
    case createObject         = 0x01
    case setPRNValue          = 0x02
    case calculateChecksum    = 0x03
    case execute              = 0x04
    case readObjectInfo       = 0x06
    case response             = 0x60
}
