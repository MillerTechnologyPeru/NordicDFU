//
//  DeviceCommand.swift
//  dfutool
//
//  Created by Alsey Coleman Miller on 9/1/18.
//

import Foundation
import GATT
import NordicDFU

#if os(macOS)
import DarwinGATT
#endif

internal protocol DeviceCommand: ArgumentableCommand {
    
    var peripheral: String { get }
    
    var scanDuration: TimeInterval { get }
    
    var filterDuplicates: Bool { get }
    
    var timeout: TimeInterval { get }
}

internal extension DeviceCommand {
    
    static var defaultScanDuration: TimeInterval { return 5.0 }
    
    static var defaultFilterDuplicates: Bool { return false }
    
    static var defaultTimeout: TimeInterval { return .gattDefaultTimeout }
}

extension DeviceCommand {
    
    func scan <Central: CentralProtocol> (_ deviceManager: NordicDeviceManager<Central>) throws -> NordicPeripheral<Central.Peripheral, Central.Advertisement> {
        
        let peripheral = self.peripheral
        
        print("Searching for \(peripheral) (\(scanDuration)s)")
        
        let start = Date()
        
        var foundDevice: NordicPeripheral<Central.Peripheral, Central.Advertisement>?
        
        try deviceManager.scan(duration: self.scanDuration, filterDuplicates: self.filterDuplicates, filterPeripherals: { $0.filter({ $0.peripheral.identifier.description == peripheral }) }, foundDevice: {
            
            // find matching peripheral by MAC address
            if $0.scanData.peripheral.identifier.description == peripheral {
                foundDevice = $0
            }
        })
        
        guard let device = foundDevice
            else { throw CommandError.notFound(peripheral) }
        
        print("Found \(peripheral) (\(String(format: "%.2f", Date().timeIntervalSince(start)))s)")
        
        return device
    }
}
