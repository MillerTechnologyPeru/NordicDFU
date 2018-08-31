//
//  SecureDFUService.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

import Foundation
import Bluetooth
import GATT

public struct SecureDFUService: GATTProfileService {
    
    public static let uuid: BluetoothUUID = .nordicSemiconductor2 // Nordic Semiconductor ASA (0xFE59)
    
    public static let isPrimary: Bool = true
    
    public static let characteristics: [GATTProfileCharacteristic.Type] = [
        SecureDFUControlPoint.self,
        SecureDFUPacket.self
    ]
}

internal extension SecureDFUService {
    
    static func calculateFirmwareRanges(_ data: Data, maxLen: Int) -> [Range<Int>] {
        
        var totalLength = data.count
        var ranges = [Range<Int>]()
        
        var partIdx = 0
        while (totalLength > 0) {
            var range : Range<Int>
            if totalLength > maxLen {
                totalLength -= maxLen
                range = (partIdx * maxLen) ..< maxLen + (partIdx * maxLen)
            } else {
                range = (partIdx * maxLen) ..< totalLength + (partIdx * maxLen)
                totalLength = 0
            }
            ranges.append(range)
            partIdx += 1
        }
        
        return ranges
    }
}

internal extension CentralProtocol {
    
    func secureDFU() throws {
        
        
    }
    
    func secureDFUSendInitPacket(data: Data) {
        
        // disable PRN
        
    }
}
