//
//  LegacyDFUService.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation
import Bluetooth
import GATT

public struct DFUService {
    
    public static let uuid = BluetoothUUID(rawValue: "00001530-1212-EFDE-1523-785FEABCD123")!
    
    public var controlPoint: DFUControlPoint
}
