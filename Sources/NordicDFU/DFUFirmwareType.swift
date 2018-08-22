//
//  FirmwareType.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Bluetooth

/// Nordic DFU Firmaware Type
public enum DFUFirmwareType: UInt8, BitMaskOption {
    
    #if swift(>=3.2)
    #elseif swift(>=3.0)
    public typealias RawValue = UInt8
    #endif
    
    case softdevice     = 0x01
    case bootloader     = 0x02
    case application    = 0x04
    
    public static let all: Set<DFUFirmwareType> = [
        .softdevice,
        .bootloader,
        .application
    ]
}
