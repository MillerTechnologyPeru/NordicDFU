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
    
    var scanTimeout: TimeInterval { get }
    
    var filterDuplicates: Bool { get }
    
    var timeout: TimeInterval { get }
}

extension DeviceCommand {
    
    func scan <Central: CentralProtocol> (_ deviceManager: NordicDeviceManager<Central>) throws -> NordicPeripheral<Central.Peripheral> {
        
        let peripheral = self.peripheral
        
        print("Searching for \(peripheral) (\(scanTimeout)s)")
        
        let start = Date()
        
        var foundDevice: NordicPeripheral<Central.Peripheral>?
        
        try deviceManager.scan(duration: self.scanTimeout, filterDuplicates: self.filterDuplicates, foundDevice: {
            
            // find matching peripheral by MAC address
            if $0.peripheral.identifier.description == peripheral {
                foundDevice = $0
                return false
            } else {
                return true // keep searching
            }
        })
        
        guard let device = foundDevice else { throw CommandError.notFound(peripheral) }
        
        print("Found \(peripheral) (\(String(format: "%.2f", Date().timeIntervalSince(start)))s)")
        
        return device
    }
}
