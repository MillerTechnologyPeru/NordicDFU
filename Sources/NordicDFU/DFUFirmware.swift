//
//  DFUFirmware.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/14/18.
//

import Foundation
import Bluetooth

/// Nordic DFU Firmware
public struct DFUFirmware {
    
    public let data: [FirmwareData]
}

public extension DFUFirmware {
    
    struct FirmwareData {
        
        /// Firmware type.
        public let type: BitMaskOptionSet<DFUFirmwareType>
        
        /// The firmware data to be sent to the DFU target.
        public let data: Data
        
        /// The whole init packet matching the current part. Data may be longer than 20 bytes.
        public let initPacket: Data?
    }
}
