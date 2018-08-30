//
//  ButtonlessDFUOpCode.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/29/18.
//

public enum ButtonlessDFUOpCode: UInt8 {
    
    case enterBootloader = 0x01
    case setName         = 0x02
    case responseCode    = 0x20
}
