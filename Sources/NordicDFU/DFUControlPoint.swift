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
    
    public static let service: GATTProfileService.Type = DFUService.self
    
    case start(DFUStartRequest)
    case initialize(DFUInitialize)
    case receiveFirmwareImage
    case validateFirmware
    case activate
    case reset
    case packetReceiptRequest(DFUPacketReceiptRequest)
    case response(DFUResponse)
    case packetReceiptNotification(DFUPacketReceiptNotification)
    
    public init?(data: Data) {
        
        guard data.isEmpty == false
            else { return nil }
        
        guard let opcode = DFUOpcode(rawValue: data[0])
            else { return nil }
        
        switch opcode {
            
        case .start:
            
            guard let request = DFUStartRequest(data: data)
                else { return nil }
            
            self = .start(request)
            
        case .initialize:
            
            guard let request = DFUInitialize(data: data)
                else { return nil }
            
            self = .initialize(request)
            
        case .receiveFirmwareImage:
            
            guard let _ = DFUReceiveFirmwareImage(data: data)
                else { return nil }
            
            self = .receiveFirmwareImage
            
        case .validateFirmware:
            
            guard let _ = DFUValidateFirmware(data: data)
                else { return nil }
            
            self = .validateFirmware
            
        case .activate:
            
            guard let _ = DFUActivate(data: data)
                else { return nil }
            
            self = .activate
            
        case .reset:
            
            guard let _ = DFUReset(data: data)
                else { return nil }
            
            self = .reset
            
        case .packetReceipt:
            
            guard let request = DFUPacketReceiptRequest(data: data)
                else { return nil }
            
            self = .packetReceiptRequest(request)
            
        case .response:
            
            guard let response = DFUResponse(data: data)
                else { return nil }
            
            self = .response(response)
            
        case .packetReceiptNotification:
            
            guard let notification = DFUPacketReceiptNotification(data: data)
                else { return nil }
            
            self = .packetReceiptNotification(notification)
        
        case .reportReceivedImageSize:
            
            return nil // not supported
        }
    }
    
    public var data: Data {
        
        return rawValue.data
    }
}

extension DFUControlPoint: RawRepresentable {
    
    public init?(rawValue: DFUMessage) {
        
        if let request = rawValue as? DFUStartRequest {
            
            self = .start(request)
            
        } else if let request = rawValue as? DFUInitialize {
            
            self = .initialize(request)
            
        } else if rawValue is DFUReceiveFirmwareImage {
            
            self = .receiveFirmwareImage
            
        } else if rawValue is DFUValidateFirmware {
            
            self = .validateFirmware
            
        } else if rawValue is DFUActivate {
            
            self = .activate
            
        } else if rawValue is DFUReset {
            
            self = .reset
            
        } else if let request = rawValue as? DFUPacketReceiptRequest {
            
            self = .packetReceiptRequest(request)
            
        } else if let response = rawValue as? DFUResponse {
            
            self = .response(response)
            
        } else if let notification = rawValue as? DFUPacketReceiptNotification {
            
            self = .packetReceiptNotification(notification)
            
        }  else {
            
            return nil
        }
    }
    
    public var rawValue: DFUMessage {
        
        switch self {
        case let .start(request): return request
        case let .initialize(request): return request
        case .receiveFirmwareImage: return DFUReceiveFirmwareImage()
        case .validateFirmware: return DFUValidateFirmware()
        case .activate: return DFUActivate()
        case .reset: return DFUReset()
        case let .packetReceiptRequest(request): return request
        case let .response(response): return response
        case let .packetReceiptNotification(notification): return notification
        }
    }
}

// MARK: - Central

internal extension CentralProtocol {
    
    func send <T: DFURequest> (_ request: T,
                               for cache: GATTConnectionCache<Peripheral>,
                               timeout: Timeout) throws {
        
        guard let foundCharacteristic = cache.characteristics.first(where: { $0.uuid == DFUControlPoint.uuid })
            else { throw CentralError.invalidAttribute(DFUControlPoint.uuid) }
        
        let expectAcknowledgement = T.acknowledge
        
        var notificationValue: ErrorValue<DFUControlPoint>?
        
        if expectAcknowledgement {
            
            try self.notify(DFUControlPoint.self, for: cache, timeout: timeout, notification: { notificationValue = $0 })
        }
        
        // send request
        try self.writeValue(request.data,
                            for: foundCharacteristic,
                            withResponse: true,
                            timeout: try timeout.timeRemaining())
        
        if expectAcknowledgement {
            
            // wait for notification
            repeat {
                
                // attempt to timeout
                try timeout.timeRemaining()
                
                // get notification response
                guard let response = notificationValue
                    else { usleep(100); continue }
                
                switch response {
                    
                case let .error(error):
                    throw error
                    
                case let .value(value):
                    
                    // stop notifications
                    try self.notify(DFUControlPoint.self, for: cache, timeout: timeout, notification: nil)
                    
                    switch value {
                        
                    case let .response(response):
                        
                        if let error = response.error {
                            
                            throw error
                            
                        } else {
                            
                            guard response.request == T.opcode
                                else { throw NordicGATTError.invalidData(response.data) }
                            
                            // success
                            return
                        }
                        
                    default:
                        
                        throw NordicGATTError.invalidData(value.data)
                    }
                    
                }
                
            } while true // keep waiting
        }
    }
}

