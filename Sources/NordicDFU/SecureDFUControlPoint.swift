//
//  SecureDFUControlPoint.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/10/18.
//

import Foundation
import Bluetooth

public enum SecureDFUControlPoint: GATTProfileCharacteristic {
    
    public static let uuid = BluetoothUUID(rawValue: "8EC90001-F315-4F60-9FB8-838830DAEA50")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.write, .notify]
    
    public static var service: GATTProfileService.Type = SecureDFUService.self
    
    case request(SecureDFURequest)
    case response(SecureDFUResponse)
    
    public init?(data: Data) {
        
        guard data.isEmpty == false
            else { return nil }
        
        guard let opcode = SecureDFUOpcode(rawValue: data[0])
            else { return nil }
        
        switch opcode {
            
        case .createObject:
            
            guard let request = SecureDFUCreateObject(data: data)
                else { return nil }
            
            self = .request(.createObject(request))
            
        case .setPRNValue:
            
            guard let request = SecureDFUSetPacketReceiptNotification(data: data)
                else { return nil }
            
            self = .request(.setPRNValue(request))
        
        case .calculateChecksum:
            
            self = .request(.calculateChecksum)
            
        case .execute:
            
            self = .request(.execute)
            
        case .readObjectInfo:
            
            guard let request = SecureDFUReadObjectInfo(data: data)
                else { return nil }
            
            self = .request(.readObjectInfo(request))
            
        case .response:
            
            guard let response = SecureDFUResponse(data: data)
                else { return nil }
            
            self = .response(response)
        }
    }
    
    public var data: Data {
        
        fatalError()
    }
}
