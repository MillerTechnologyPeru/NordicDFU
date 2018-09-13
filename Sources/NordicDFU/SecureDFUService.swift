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
        
        @discardableResult
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
        
        func calculateChecksum(timeout: TimeInterval) throws -> SecureDFUCalculateChecksumResponse {
            
            let response = try self.request(.calculateChecksum, timeout: timeout)
            
            switch response {
                
            case let .calculateChecksum(calculateChecksum):
                return calculateChecksum
            default:
                throw GATTError.invalidData(response.data)
            }
        }
    }
}

internal extension CentralProtocol {
    
    func secureFirmwareUpload(_ firmwareData: DFUFirmware.FirmwareData,
                              packetReceiptNotification: SecureDFUSetPacketReceiptNotification,
                              for cache: GATTConnectionCache<Peripheral>,
                              timeout: TimeInterval) throws {
        
        let controlPointNotification = try SecureDFUService.ControlPointNotification(central: self,
                                                                                      cache: cache,
                                                                                      timeout: timeout)
        
        guard let packetCharacteristic = cache.characteristics.first(where: { $0.uuid == SecureDFUPacket.uuid })
            else { throw CentralError.invalidAttribute(SecureDFUPacket.uuid) }
        
        // upload init packet
        if let data = firmwareData.initPacket {
            
            try secureInitPacketUpload(data, controlPoint: controlPointNotification, packet: packetCharacteristic, timeout: timeout)
        }
        
        // upload firmware data
        try secureFirmwareDataUpload(firmwareData.data,
                                     packetReceiptNotification: packetReceiptNotification,
                                     controlPoint: controlPointNotification,
                                     packet: packetCharacteristic,
                                     timeout: timeout)
    }
}

fileprivate extension CentralProtocol {
    
    func secureDataPacketUpload(_ data: Data,
                                packet: Characteristic<Peripheral>,
                                timeout: TimeInterval) throws {
        
        // set chunk size
        let mtu = try maximumTransmissionUnit(for: packet.peripheral)
        
        // Data may be sent in up-to-20-bytes packets (if MTU is 23)
        let packetSize = Int(mtu.rawValue - 3)
        
        // send packets packets
        try stride(from: 0, to: data.count, by: packetSize).forEach {
            let packetData = data.subdataNoCopy(in: $0 ..< min($0 + packetSize, data.count))
            try writeValue(packetData, for: packet, withResponse: false, timeout: timeout)
        }
    }
    
    func secureInitPacketUpload(_ data: Data,
                                controlPoint: SecureDFUService.ControlPointNotification<Self>,
                                packet: Characteristic<Peripheral>,
                                timeout timeoutInterval: TimeInterval) throws {
        
        var timeout = Timeout(timeout: timeoutInterval)
        
        // start uploading command object
        let objectInfo = try controlPoint.readObjectInfo(type: .command,
                                                         timeout: try timeout.timeRemaining())
        
        // verify object size
        guard Int(objectInfo.maxSize) >= data.count else {
            
            assertionFailure("Data too big (\(data.count)) for \(objectInfo)")
            throw GATTError.invalidData(data)
        }
        
        // create object
        try controlPoint.request(.createObject(SecureDFUCreateObject(type: .command, size: UInt32(data.count))),
                                 timeout: try timeout.timeRemaining())
        
        // disable PRN
        try controlPoint.request(.setPRNValue(0),
                                 timeout: try timeout.timeRemaining())
        
        // send data...
        try secureDataPacketUpload(data, packet: packet, timeout: timeoutInterval)
        
        timeout = Timeout(timeout: timeoutInterval)
        
        // calculate checksum
        let checksumResponse = try controlPoint.calculateChecksum(timeout: try timeout.timeRemaining())
        
        let expectedChecksum = CRC32(data: data).crc
        
        guard checksumResponse.crc == expectedChecksum
            else { throw GATTError.invalidChecksum(checksumResponse.crc, expected: expectedChecksum) }
        
        // execute command
        try controlPoint.request(.execute, timeout: try timeout.timeRemaining())
    }
    
    func secureFirmwareDataUpload(_ data: Data,
                                  packetReceiptNotification: SecureDFUSetPacketReceiptNotification,
                                  controlPoint: SecureDFUService.ControlPointNotification<Self>,
                                  packet: Characteristic<Peripheral>,
                                  timeout timeoutInterval: TimeInterval) throws {
        
        var timeout = Timeout(timeout: timeoutInterval)
        
        // start uploading command object
        let objectInfo = try controlPoint.readObjectInfo(type: .data,
                                                         timeout: try timeout.timeRemaining())
        
        // enable PRN notifications
        try controlPoint.request(.setPRNValue(packetReceiptNotification),
                                 timeout: try timeout.timeRemaining())
        
        // send packets
        let objectSize = Int(objectInfo.maxSize)
        let dataObjects: [Data] = stride(from: 0, to: data.count, by: objectSize).map {
            data.subdataNoCopy(in: $0 ..< min($0 + objectSize, data.count))
        }
        
        // create data objects on peripheral
        for dataObject in dataObjects {
            
            timeout = Timeout(timeout: timeoutInterval)
            
            let createObject = SecureDFUCreateObject(type: .data, size: objectInfo.maxSize)
            
            // create data object
            try controlPoint.request(.createObject(createObject), timeout: try timeout.timeRemaining())
            
            // upload packet
            try secureDataPacketUpload(dataObject, packet: packet, timeout: timeoutInterval)
            
            timeout = Timeout(timeout: timeoutInterval)
            
            // validate checksum
            let checksumResponse = try controlPoint.calculateChecksum(timeout: try timeout.timeRemaining())
            
            let expectedChecksum = CRC32(data: dataObject).crc
            
            guard checksumResponse.crc == expectedChecksum
                else { throw GATTError.invalidChecksum(checksumResponse.crc, expected: expectedChecksum) }
            
            // execute command
            try controlPoint.request(.execute, timeout: try timeout.timeRemaining())
        }
    }
}
