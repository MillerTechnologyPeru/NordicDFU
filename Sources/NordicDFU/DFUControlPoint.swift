//
//  DFUControlPoint.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation
import Bluetooth
import GATT

public struct DFUControlPoint: GATTProfileCharacteristic {
    
    public static let uuid = BluetoothUUID(rawValue: "00001531-1212-EFDE-1523-785FEABCD123")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.write, .notify]
    
    public static var service: GATTProfileService.Type = DFUService.self
    
    public init?(data: Data) {
        
        fatalError()
    }
    
    public var data: Data {
        
        fatalError()
    }
}

public extension CentralProtocol {
    
    func send <T: DFURequest> (_ request: T) throws {
        
        
    }
}

