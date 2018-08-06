//
//  DFUOpcode.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

/// Nordic DFU Opcodes
public enum DFUOpcode: UInt8 {
    
    // Request
    case start                       = 1
    case initialize                  = 2
    case receiveFirmwareImage        = 3
    case validateFirmware            = 4
    case activate                    = 5
    case reset                       = 6
    case reportReceivedImageSize     = 7
    case packetReceipt               = 8
    
    // Response
    case response                    = 16
    case packetReceiptNotification   = 17
}
