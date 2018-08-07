//
//  DFUControlPoint.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation
import Bluetooth
import GATT

public enum DFUControlPoint: GATTProfileCharacteristic {
    
    public static let uuid = BluetoothUUID(rawValue: "00001531-1212-EFDE-1523-785FEABCD123")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.write, .notify]
    
    public static var service: GATTProfileService.Type = DFUService.self
    
    case start(DFUStartRequest)
    case initialize(DFUInitialize)
    case receiveFirmwareImage
    case validateFirmware
    case activate
    case reset
    case packetReceiptRequest(DFUPacketReceiptNotificationRequest)
    case response(DFUResponse)
    case packetReceiptNotification(DFUPacketReceiptNotification)
    /*
    public init?(request: DFURequest) {
        
        if let request = request as? DFUStartRequest {
            
            self = .start(request)
            
        } else if let request = request as? DFUInitialize {
            
            self = .initialize(request)
            
        } else if let request = request as? DFUReceiveFirmwareImage {
            
            self = .receiveFirmwareImage
            
        } else if let request = request as? DFUValidateFirmware {
            
            self = .validateFirmware
            
        } else if let request = request as? DFUActivate {
            
            self = .start(request)
            
        } else if let request = request as? DFUReset {
            
            self = .start(request)
            
        } else if let request = request as? DFUStartRequest {
            
            self = .start(request)
            
        } else if let request = request as? DFUStartRequest {
            
            self = .start(request)
            
        } else {
            
            return nil
        }
    }
    */
    public init?(data: Data) {
        
        guard data.isEmpty == false
            else { return nil }
        
        guard let opcode = DFUOpcode(rawValue: data[0])
            else { return nil }
        
        switch opcode {
            
        case .start:
            let request = DFUStartRequest(firmwareType: <#T##FirmwareType#>)
            self = .start(<#T##DFUStartRequest#>)
        }
    }
    
    public var data: Data {
        
        switch self {
        case let .start(request): return request.data
        case let .initialize
        }
    }
}

public extension CentralProtocol {
    
    func send <T: DFURequest> (_ request: T) throws {
        
        
    }
}

