//
//  DeviceManager.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/8/18.
//

import Foundation
import Bluetooth
import GATT

/// Nordic GATT Central client.
public final class NordicDeviceManager <Central: CentralProtocol> {
    
    public typealias Peripheral = Central.Peripheral
    
    public typealias Advertisement = Central.Advertisement
    
    // MARK: - Initialization
    
    public init(central: Central) {
        
        self.central = central
    }
    
    // MARK: - Properties
    
    /// GATT Central Manager.
    public let central: Central
    
    /// The log message handler.
    public var log: ((String) -> ())?
    
    /**
     The number of packets of firmware data to be received by the DFU target before sending
     a new Packet Receipt Notification.
     If this value is 0, the packet receipt notification will be disabled by the DFU target.
     Default value is 12.
     
     PRNs are no longer required on iOS 11 and MacOS 10.13 or newer, but make sure
     your device is able to be updated without. Old SDKs, before SDK 7 had very slow
     memory management and could not handle packets that fast. If your device
     is based on such SDK it is recommended to leave the default value.
     
     Disabling PRNs on iPhone 8 with iOS 11.1.2 increased the speed from 1.7 KB/s to 2.7 KB/s
     on DFU from SDK 14.1 where packet size is 20 bytes (higher MTU not supported yet).
     
     On older versions, higher values of PRN (~20+), or disabling it, may speed up
     the upload process, but also cause a buffer overflow and hang the Bluetooth adapter.
     Maximum verified values were 29 for iPhone 6 Plus or 22 for iPhone 7, both iOS 10.1.
     */
    public var packetReceiptNotification: SecureDFUSetPacketReceiptNotification = 12
    
    /// Scans for nearby devices.
    ///
    /// - Parameter duration: The duration of the scan.
    ///
    /// - Parameter event: Callback for a found device.
    public func scan(duration: TimeInterval,
                     timeout: TimeInterval = .gattDefaultTimeout,
                     filterDuplicates: Bool = true,
                     filterPeripherals: ([ScanData<Peripheral, Advertisement>]) -> ([ScanData<Peripheral, Advertisement>]) = { return $0 },
                     foundDevice: @escaping (NordicPeripheral<Peripheral>) -> ()) throws {
        
        var scanResults = try central.scan(duration: duration, filterDuplicates: filterDuplicates)
        
        scanResults = filterPeripherals(scanResults)
        
        for scanResult in scanResults {
            
            do {
                
                let timeout = Timeout(timeout: timeout)
                
                let services = [DFUService.uuid, SecureDFUService.uuid]
                
                try central.device(for: scanResult.peripheral, filterServices: services, timeout: timeout) { [unowned self] (cache) in
                    
                    guard let peripheral = self.peripheral(for: scanResult.peripheral, cache: cache)
                        else { return }
                    
                    foundDevice(peripheral)
                }
            }
            
            catch { log?("Error validating \(scanResult.peripheral): \(error)") }
        }
    }
    
    /// Jump to DFU
    public func enterBootloader(for peripheral: Peripheral, timeout: TimeInterval = .gattDefaultTimeout) throws {
        
        let timeout = Timeout(timeout: timeout)
        
        try central.device(for: peripheral, timeout: timeout) { [unowned self] (connectionCache) in
            
            guard let peripheral = self.peripheral(for: peripheral, cache: connectionCache)
                else { throw GATTError.invalidPeripheral }
            
            switch peripheral.type {
                
            case .secure:
                
                try self.central.buttonlessDFU(.enterBootloader, for: connectionCache, timeout: timeout)
                
            case .legacy:
                
                // not supported
                throw CentralError.invalidAttribute(SecureDFUService.uuid)
            }
        }
    }
    
    /// Upload firmware.
    public func uploadFirmware(_ firmware: DFUFirmware,
                               for peripheral: Peripheral,
                               timeout: TimeInterval = .gattDefaultTimeout,
                               log: ((SecureDFUEvent) -> ())? = nil) throws {
        
        let timeout = Timeout(timeout: timeout)
        
        let packetReceiptNotification = self.packetReceiptNotification
        
        try central.device(for: peripheral, timeout: timeout) { [unowned self] (connectionCache) in
            
            guard let peripheral = self.peripheral(for: peripheral, cache: connectionCache)
                else { throw GATTError.invalidPeripheral }
            
            for firmwareData in firmware.data {
                
                switch peripheral.type {
                    
                case .secure:
                    
                    try self.central.secureFirmwareUpload(firmwareData,
                                                          packetReceiptNotification: packetReceiptNotification,
                                                          for: connectionCache,
                                                          timeout: timeout.timeout,
                                                          log: log)
                    
                case .legacy:
                    
                    fatalError("Not implemented")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    func peripheral(for peripheral: Peripheral,
                    cache: GATTConnectionCache<Peripheral>) -> NordicPeripheral<Peripheral>? {
        
        let type: NordicPeripheralType
        let mode: NordicPeripheralMode
        
        if cache.characteristics.contains(where: { ButtonlessDFUExperimental.matches($0) }) {
            
            type = .secure
            mode = .enterBootloader
            
        } else if cache.characteristics.contains(where: { ButtonlessDFUWithBondSharing.matches($0) }) {
            
            type = .secure
            mode = .enterBootloader
            
        } else if cache.characteristics.contains(where: { ButtonlessDFUWithoutBondSharing.matches($0) }) {
            
            type = .secure
            mode = .enterBootloader
            
        } else if cache.characteristics.contains(where: { SecureDFUControlPoint.matches($0) }),
            cache.characteristics.contains(where: { SecureDFUPacket.matches($0) }) {
            
            type = .secure
            mode = .uploadFirmware
            
        } else if cache.characteristics.contains(where: { DFUControlPoint.matches($0) }),
            cache.characteristics.contains(where: { DFUPacket.matches($0) }) {
            
            type = .legacy
            mode = .uploadFirmware
            
        } else {
            
            return nil
        }
        
        return NordicPeripheral(peripheral: peripheral, type: type, mode: mode)
    }
}

public struct NordicPeripheral <Peripheral: Peer> {
    
    public let peripheral: Peripheral
    
    public let type: NordicPeripheralType
    
    public let mode: NordicPeripheralMode
}

public enum NordicPeripheralType {
    
    case legacy
    case secure
}

public enum NordicPeripheralMode {
    
    case enterBootloader
    case uploadFirmware
}
