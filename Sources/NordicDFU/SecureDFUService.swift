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
                              log: ((SecureDFUEvent) -> ())? = nil) throws {
        
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
    
    final class DFUExecutor <Central: CentralProtocol> {
        
        let central: Central
        
        let controlPoint: ControlPointNotification<Central>
        
        let packet: Packet<Central>
        
        let log: ((SecureDFUEvent) -> ())?
        
        init(central: Central,
             cache: GATTConnectionCache<Central.Peripheral>,
             timeout: TimeInterval,
             log: ((SecureDFUEvent) -> ())? = nil) throws {
            
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
            
            // reset notification queue for next history
            defer { controlPoint.reset() }
            
            // start uploading command object
            let objectInfo = try controlPoint.readObjectInfo(type: type,
                                                             timeout: timeoutInterval)
            
            // enable / disable PRN notifications
            try controlPoint.request(.setPRNValue(packetReceiptNotification),
                                     timeout: timeoutInterval)
            
            // send packets
            let objectSize = Int(objectInfo.maxSize)
            let dataObjects: [Data] = stride(from: 0, to: data.count, by: objectSize).map {
                data.subdataNoCopy(in: $0 ..< min($0 + objectSize, data.count))
            }
            
            var dataObjectOffset = 0
            var lastPRNOffset: UInt32 = 0
            
            // create data objects on peripheral
            for (objectIndex, dataObject) in dataObjects.enumerated() {
                
                // create data object
                let createObject = SecureDFUCreateObject(type: type, size: UInt32(dataObject.count))
                try controlPoint.request(.createObject(createObject), timeout: timeoutInterval)
                
                var packetsSincePRN = 0
                
                // upload packet
                try packet.upload(dataObject, timeout: timeoutInterval) { [unowned self] (range) in
                    
                    packetsSincePRN += 1
                    
                    // bytes written so far
                    let writtenBytes = dataObjectOffset + range.lowerBound + range.count
                    
                    self.log?(.write(type, offset: writtenBytes, total: data.count))
                    
                    // validate PRN
                    guard packetReceiptNotification > 0 else { return }
                    
                    // wait for PRN
                    if packetsSincePRN == Int(packetReceiptNotification.rawValue) {
                        
                        while self.controlPoint.checksum(for: UInt32(writtenBytes)) == nil {
                            
                            // wait for PRN
                            usleep(100)
                        }
                        
                        packetsSincePRN = 0
                    }
                    
                    // every PRN value (e.g. 12) packets, verify checksum
                    if let checksum = self.controlPoint.lastChecksum,
                        checksum.offset > lastPRNOffset,
                        Int(checksum.offset) <= writtenBytes {
                        
                        lastPRNOffset = checksum.offset
                        
                        let sentData = data.subdataNoCopy(in: 0 ..< Int(checksum.offset))
                        let expectedChecksum = CRC32(data: sentData).crc
                        
                        guard checksum.crc == expectedChecksum
                            else { throw GATTError.invalidChecksum(checksum.crc, expected: expectedChecksum) }
                        
                         self.log?(.verify(type, offset: Int(checksum.offset), checksum: checksum.crc))
                    }
                }
                
                // send data object
                dataObjectOffset += dataObject.count
                
                // validate checksum for created object
                let checksum = try controlPoint.calculateChecksum(timeout: timeoutInterval)
                let sentData = data.subdataNoCopy(in: 0 ..< dataObjectOffset)
                let expectedChecksum = CRC32(data: sentData).crc
                
                guard checksum.crc == expectedChecksum
                    else { throw GATTError.invalidChecksum(checksum.crc, expected: expectedChecksum) }
                
                lastPRNOffset = checksum.offset
                
                self.log?(.verify(type, offset: Int(checksum.offset), checksum: checksum.crc))
                
                // execute command
                try controlPoint.request(.execute, timeout: timeoutInterval)
                
                self.log?(.execute(type, index: objectIndex, total: dataObjects.count))
            }
        }
    }
}

internal extension SecureDFUService {
    
    final class Packet <Central: CentralProtocol> {
        
        let central: Central
        
        let characteristic: Characteristic<Central.Peripheral>
        
        let log: ((SecureDFUEvent) -> ())?
        
        init(central: Central,
             cache: GATTConnectionCache<Central.Peripheral>,
             log: ((SecureDFUEvent) -> ())? = nil) throws {
            
            guard let characteristic = cache.characteristics.first(where: { $0.uuid == SecureDFUPacket.uuid })
                else { throw CentralError.invalidAttribute(SecureDFUPacket.uuid) }
            
            self.central = central
            self.characteristic = characteristic
            self.log = log
        }
        
        func upload(_ data: Data,
                    timeout: TimeInterval,
                    didWrite: ((CountableRange<Int>) throws -> ())) throws {
            
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
                try central.writeValue(packetData, for: characteristic, withResponse: false, timeout: timeout)
                try didWrite(range)
            }
        }
    }
}

internal extension SecureDFUService {
    
    final class ControlPointNotification <Central: CentralProtocol> {
        
        let central: Central
        
        let characteristic: Characteristic<Central.Peripheral>
        
        let log: ((SecureDFUEvent) -> ())?
        
        private var notifications = [Notification]()
        
        init(central: Central,
             cache: GATTConnectionCache<Central.Peripheral>,
             timeout: TimeInterval,
             log: ((SecureDFUEvent) -> ())? = nil) throws {
            
            guard let characteristic = cache.characteristics.first(where: { $0.uuid == SecureDFUControlPoint.uuid })
                else { throw CentralError.invalidAttribute(SecureDFUControlPoint.uuid) }
            
            self.central = central
            self.characteristic = characteristic
            self.log = log
            
            // enable notifications
            try central.notify(SecureDFUControlPoint.self,
                               for: characteristic,
                               timeout: Timeout(timeout: timeout),
                               notification: { [weak self] in self?.notification($0) })
        }
        
        private func notification(_ notification: ErrorValue<SecureDFUControlPoint>) {
            
            self.notifications.append(Notification(value: notification))
        }
        
        func reset() {
            
            self.notifications = []
        }
        
        var lastChecksum: SecureDFUCalculateChecksumResponse? {
            
            let notifications = self.notifications
            
            for notification in notifications.reversed() {
                
                guard case let .value(.response(.calculateChecksum(checksum))) = notification.value
                    else { continue }
                
                return checksum
            }
            
            return nil
        }
        
        func checksum(for offset: UInt32) -> SecureDFUCalculateChecksumResponse? {
            
            let notifications = self.notifications
            
            for notification in notifications.reversed() {
                
                guard case let .value(.response(.calculateChecksum(checksum))) = notification.value
                    else { continue }
                
                guard checksum.offset == offset
                    else { continue }
                
                return checksum
            }
            
            return nil
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
                
                return try notification.response()
                
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
    }
}

private extension SecureDFUService.ControlPointNotification {
    
    final class Notification {
        
        let date: Date
        
        let value: ErrorValue<SecureDFUControlPoint>
        
        init(date: Date = Date(),
             value: ErrorValue<SecureDFUControlPoint>) {
            
            self.date = date
            self.value = value
        }
        
        func response() throws -> SecureDFUResponse {
            
            switch value {
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
        }
    }
}

public enum SecureDFUEvent: Equatable, Hashable {
    
    case write(SecureDFUProcedureType, offset: Int, total: Int)
    case verify(SecureDFUProcedureType, offset: Int, checksum: UInt32)
    case execute(SecureDFUProcedureType, index: Int, total: Int)
}
