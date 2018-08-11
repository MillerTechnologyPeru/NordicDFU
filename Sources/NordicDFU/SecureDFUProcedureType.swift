//
//  SecureDFUProcedureType.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

public enum SecureDFUProcedureType: UInt8 {
    
    case command = 0x01
    case data    = 0x02
}
