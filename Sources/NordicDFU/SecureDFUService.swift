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

fileprivate extension SecureDFUService {
    
    fileprivate final class ControlPointNotification <Central: CentralProtocol> {
        
        let central: Central
        
        let characteristic: Characteristic<Central.Peripheral>
        
        let timeout: TimeInterval
        
        private var notificationValue: ErrorValue<SecureDFUControlPoint>?
        
        deinit {
            
            do {
                
                // disable notifications
                try central.notify(SecureDFUControlPoint.self,
                                   for: characteristic,
                                   timeout: Timeout(timeout: timeout),
                                   notification: nil)
            }
            
            catch { assertionFailure("Could not disable notification: \(error)") }
        }
        
        init(central: Central, cache: GATTConnectionCache<Central.Peripheral>, timeout: TimeInterval) throws {
            
            guard let characteristic = cache.characteristics.first(where: { $0.uuid == SecureDFUControlPoint.uuid })
                else { throw CentralError.invalidAttribute(SecureDFUControlPoint.uuid) }
            
            self.central = central
            self.timeout = timeout
            self.characteristic = characteristic
            
            // enable notifications
            try central.notify(SecureDFUControlPoint.self,
                           for: characteristic,
                           timeout: Timeout(timeout: timeout),
                           notification: { [weak self] in self?.notificationValue = $0 })
        }
        
        func request(_ request: SecureDFURequest, timeout: TimeInterval) throws -> SecureDFUResponse {
            
            let timeout = Timeout(timeout: timeout)
            
            // send request
            try central.writeValue(request.data,
                                   for: characteristic,
                                   withResponse: true,
                                   timeout: try timeout.timeRemaining())
            
            // wait for notification
            repeat {
                
                // attempt to timeout
                try timeout.timeRemaining()
                
                // get notification response
                guard let response = notificationValue
                    else { usleep(100); continue }
                
                // clear stored value
                notificationValue = nil
                
                switch response {
                    
                case let .error(error):
                    throw error
                    
                case let .value(value):
                    
                    switch value {
                        
                    case let .response(response):
                        switch response {
                        case let .error(error):
                            throw error
                        case let .extendedError(error):
                            throw error
                        default:
                            return response
                        }
                        
                    case .request:
                        throw GATTError.invalidData(value.data)
                    }
                }
                
            } while true // keep waiting
        }
        
        func readObjectInfo(type: SecureDFUProcedureType, timeout: TimeInterval) throws -> SecureDFUReadObjectInfoResponse {
            
            let request = SecureDFUReadObjectInfo(type: type)
            
            let response = try self.request(.readObjectInfo(request), timeout: timeout)
            
            switch response {
                
            case let .readObject(readInfo):
                return readInfo
            default:
                throw GATTError.invalidData(response.data)
            }
        }
        
        func setPRNValue(_ value: SecureDFUSetPacketReceiptNotification, timeout: TimeInterval) throws -> SecureDFUPacketReceiptNotification {
            
            let response = try self.request(.setPRNValue(value), timeout: timeout)
            
            switch response {
            case let .calculateChecksum(checksum):
                return checksum
            default:
                throw GATTError.invalidData(response.data)
            }
        }
    }
}

internal extension CentralProtocol {
    
    func secureFirmwareUpload(_ firmwareData: DFUFirmware.FirmwareData,
                              for cache: GATTConnectionCache<Peripheral>,
                              timeout: TimeInterval) throws {
        
        let controlPointNotification = try SecureDFUService.ControlPointNotification(central: self,
                                                                                      cache: cache,
                                                                                      timeout: timeout)
        
        // upload init packet
        if let initPacket = firmwareData.initPacket {
            
            
        }
        
        // upload firmware data
        
    }
}

fileprivate extension CentralProtocol {
    
    func secureInitPacketUpload(data: Data,
                                controlPoint: SecureDFUService.ControlPointNotification<Self>,
                                timeout timeoutInterval: TimeInterval) throws {
        
        let timeout = Timeout(timeout: timeoutInterval)
        
        // start uploading command object
        let objectInfo = try controlPoint.readObjectInfo(type: .command,
                                                         timeout: try timeout.timeRemaining())
        
        // create object
        try controlPoint.request(.createObject(SecureDFUCreateObject(type: .command, size: UInt32(data.count))),
                                 timeout: try timeout.timeRemaining())
        
        // disable PRN
        
        
    }
}
