//
//  DFUStream.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/17/18.
//

import Foundation

/**
 * The stream to read firmware from.
 */
internal protocol DFUStream {
    /// Returns the 1-based number of the current part.
    var currentPart: Int { get }
    /// Number of parts to be sent.
    var parts: Int { get }
    /// The size of each component of the firmware.
    var size: DFUFirmwareSize { get }
    /// The size of each component of the firmware from the current part.
    var currentPartSize: DFUFirmwareSize { get }
    /// The type of the current part. See FIRMWARE_TYPE_* constants.
    var currentPartType: UInt8 { get }
    
    /// The firmware data to be sent to the DFU target.
    var data: Data { get }
    /// The whole init packet matching the current part. Data may be longer than 20 bytes.
    var initPacket: Data? { get }
    
    /**
     Returns true if there is another part to be send.
     
     - returns: true if there is at least one byte of data not sent in the current packet
     */
    func hasNextPart() -> Bool
    /**
     Switches the stream to the second part.
     */
    func switchToNextPart()
}
