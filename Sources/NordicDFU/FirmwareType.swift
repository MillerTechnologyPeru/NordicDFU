//
//  FirmwareType.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

/// Nordic DFU Firmaware Type
public enum FirmwareType: UInt8 {
    
    case softdevice     = 0x01
    case bootloader     = 0x02
    case application    = 0x04
}
