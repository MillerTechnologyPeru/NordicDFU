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

internal extension CentralProtocol {
    
    func secureFirmwareUpload(_ firmwareData: DFUFirmware.FirmwareData,
                              packetReceiptNotification: SecureDFUSetPacketReceiptNotification,
                              for cache: GATTConnectionCache<Peripheral>,
                              timeout: TimeInterval,
                              log: ((String) -> ())? = nil) throws {
        
        let dfu = try SecureDFUService.DFUExecutor(central: self,
                                                   cache: cache,
                                                   timeout: timeout,
                                                   log: log)
        
        // upload init packet
        if let data = firmwareData.initPacket {
            
            try dfu.upload(data, type: .command, packetReceiptNotification: 0, timeout: timeout)
        }
        
        // upload firmware data
        try dfu.upload(firmwareData.data,
                       type: .data,
                       packetReceiptNotification: packetReceiptNotification,
                       timeout: timeout)
    }
}

internal extension SecureDFUService {
    
    internal final class DFUExecutor <Central: CentralProtocol> {
        
        let central: Central
        
        let controlPoint: ControlPointNotification<Central>
        
        let packet: Packet<Central>
        
        let log: ((String) -> ())?
        
        init(central: Central,
             cache: GATTConnectionCache<Central.Peripheral>,
             timeout: TimeInterval,
             log: ((String) -> ())? = nil) throws {
            
            self.central = central
            self.log = log
            
            self.controlPoint = try ControlPointNotification(central: central,
                                                             cache: cache,
                                                             timeout: timeout)
            
            self.packet = try Packet(central: central,
                                     cache: cache)
        }
        
        func upload(_ data: Data,
                    type: SecureDFUProcedureType,
                    packetReceiptNotification: SecureDFUSetPacketReceiptNotification = 0,
                    timeout timeoutInterval: TimeInterval) throws {
            
            // start uploading command object
            let objectInfo = try controlPoint.readObjectInfo(type: type,
                                                             timeout: timeoutInterval)
            
            // enable PRN notifications
            try controlPoint.request(.setPRNValue(packetReceiptNotification),
                                     timeout: timeoutInterval)
            
            // send packets
            let objectSize = Int(objectInfo.maxSize)
            let dataObjects: [Data] = stride(from: 0, to: data.count, by: objectSize).map {
                data.subdataNoCopy(in: $0 ..< min($0 + objectSize, data.count))
            }
            
            var offset = 0
            var writtenDataPackets = 0
            
            // create data objects on peripheral
            for dataObject in dataObjects {
                
                // create data object
                let createObject = SecureDFUCreateObject(type: type, size: UInt32(dataObject.count))
                try controlPoint.request(.createObject(createObject), timeout: timeoutInterval)
                
                // upload packet
                if packetReceiptNotification > 0 {
                    
                    // wait for PRN
                    try packet.upload(dataObject, timeout: timeoutInterval) { [unowned self] (range) in
                        
                        writtenDataPackets += 1
                        
                        // every PRN value (e.g. 12) packets, wait for notification
                        if writtenDataPackets % Int(packetReceiptNotification.rawValue) == 0 {
                            
                            let writtenBytes = offset + range.lowerBound + range.count
                            
                            guard let notification = try? self.controlPoint.packetReceiptNotification(for: UInt32(writtenBytes), timeout: 5)
                                else { return }
                            
                            let sentData = data.subdataNoCopy(in: 0 ..< writtenBytes)
                            let expectedChecksum = CRC32(data: sentData).crc
                            
                            guard notification.crc == expectedChecksum
                                else { throw GATTError.invalidChecksum(notification.crc, expected: expectedChecksum) }
                        }
                    }
                    
                } else {
                    
                    // dont wait for PRN
                    try packet.upload(dataObject, timeout: timeoutInterval)
                }
                
                // send data object
                offset += dataObject.count
                
                // validate checksum for created object
                let checksumResponse = try controlPoint.calculateChecksum(timeout: timeoutInterval)
                let sentData = data.subdataNoCopy(in: 0 ..< offset)
                let expectedChecksum = CRC32(data: sentData).crc
                
                guard checksumResponse.crc == expectedChecksum
                    else { throw GATTError.invalidChecksum(checksumResponse.crc, expected: expectedChecksum) }
                
                // execute command
                try controlPoint.request(.execute, timeout: timeoutInterval)
            }
        }
    }
}

internal extension SecureDFUService {
    
    final class Packet <Central: CentralProtocol> {
        
        let central: Central
        
        let characteristic: Characteristic<Central.Peripheral>
        
        let log: ((String) -> ())?
        
        init(central: Central,
             cache: GATTConnectionCache<Central.Peripheral>,
             log: ((String) -> ())? = nil) throws {
            
            guard let characteristic = cache.characteristics.first(where: { $0.uuid == SecureDFUPacket.uuid })
                else { throw CentralError.invalidAttribute(SecureDFUPacket.uuid) }
            
            self.central = central
            self.characteristic = characteristic
            self.log = log
        }
        
        func upload(_ data: Data,
                    timeout: TimeInterval,
                    didWrite: ((CountableRange<Int>) throws -> ())? = nil) throws {
            
            // set chunk size
            let mtu = try central.maximumTransmissionUnit(for: characteristic.peripheral)
            
            // Data may be sent in up-to-20-bytes packets (if MTU is 23)
            let packetSize = Int(mtu.rawValue - 3)
            
            // calculate subranges
            let packetRanges = stride(from: 0, to: data.count, by: packetSize).map {
                $0 ..< min($0 + packetSize, data.count)
            }
            
            // send packets
            try packetRanges.forEach { (range) in
                let packetData = data.subdataNoCopy(in: range)
                try central.writeValue(packetData, for: characteristic, withResponse: true, timeout: timeout)
                try didWrite?(range) // block or whatever here
            }
        }
    }
}

internal extension SecureDFUService {
    
    final class ControlPointNotification <Central: CentralProtocol> {
        
        let central: Central
        
        let characteristic: Characteristic<Central.Peripheral>
        
        let log: ((String) -> ())?
        
        private var notifications = [(date: Date, value: ErrorValue<SecureDFUControlPoint>)]()
        
        init(central: Central,
             cache: GATTConnectionCache<Central.Peripheral>,
             timeout: TimeInterval,
             log: ((String) -> ())? = nil) throws {
            
            guard let characteristic = cache.characteristics.first(where: { $0.uuid == SecureDFUControlPoint.uuid })
                else { throw CentralError.invalidAttribute(SecureDFUControlPoint.uuid) }
            
            self.central = central
            self.characteristic = characteristic
            self.log = log
            
            // enable notifications
            try central.notify(SecureDFUControlPoint.self,
                               for: characteristic,
                               timeout: Timeout(timeout: timeout),
                               notification: { [weak self] in self?.notifications.append((Date(), $0)) })
        }
        
        func waitForNotification(timeout: Timeout) throws -> SecureDFUResponse {
            
            // wait for notification
            repeat {
                
                // attempt to timeout
                try timeout.timeRemaining()
                
                // recent notifications
                let newNotifications = notifications
                    .filter { $0.date > timeout.start }
                
                // get notification response
                guard let notification = newNotifications.first
                    else { usleep(100); continue }
                
                switch notification.value {
                    
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
        
        @discardableResult
        func request(_ request: SecureDFURequest, timeout: TimeInterval) throws -> SecureDFUResponse {
            
            let timeout = Timeout(timeout: timeout)
            
            // send request
            try central.writeValue(request.data,
                                   for: characteristic,
                                   withResponse: true,
                                   timeout: try timeout.timeRemaining())
            
            return try waitForNotification(timeout: timeout)
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
        
        func packetReceiptNotification(for offset: UInt32, timeout: TimeInterval) throws -> SecureDFUPacketReceiptNotification {
            
            let timeout = Timeout(timeout: timeout)
            
            // wait for notification
            repeat {
                
                // attempt to timeout
                try timeout.timeRemaining()
                
                for notification in notifications.reversed() {
                    
                    guard case let .value(.response(.calculateChecksum(checksum))) = notification.value
                        else { continue }
                    
                    if checksum.offset == offset {
                        
                        // received required notification
                        return checksum
                        
                    } else if checksum.offset > offset {
                        
                        // recieved larger notification
                        continue
                        
                    } else {
                        
                        // offset smaller, havent recieved notification yet
                        break
                    }
                }
                
                // not found
                sleep(1)
                
            } while true // keep waiting
        }
    }
}
