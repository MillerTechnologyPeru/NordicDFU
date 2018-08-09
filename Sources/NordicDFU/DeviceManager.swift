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
    public var log: ((String) -> ())? {
        
        get { return central.log }
        
        set { central.log = newValue }
    }
    
    internal let profiles: [NordicGATTProfile.Type] = [
        NordicLegacyDFUProfile.self
    ]
    
    /// Scans for nearby devices.
    ///
    /// - Parameter duration: The duration of the scan.
    ///
    /// - Parameter event: Callback for a found device.
    public func scan(duration: TimeInterval,
                     timeout: TimeInterval,
                     filterDuplicates: Bool = true) throws -> [Peripheral: GATTProfile.Type] {
        
        let scanResults = try central.scan(duration: duration, filterDuplicates: filterDuplicates)
        
        let timeout = Timeout(timeout: timeout)
        
        var peripherals = [Peripheral: GATTProfile.Type]()
        
        for scanResult in scanResults {
            
            let peripheral = scanResult.peripheral
            
            try central.connect(to: peripheral, timeout: try timeout.timeRemaining())
            
            defer { central.disconnect(peripheral: peripheral) }
            
            // discover services
            let services = try central.discoverServices([], for: peripheral, timeout: timeout.timeRemaining())
            
            for profile in profiles {
                
                for service in profile.services {
                    
                    // vreify service exists
                    guard services.contains(where: { $0.uuid == service.uuid })
                        else { break }
                }
                
                peripherals[peripheral] = profile
                
                break
            }
        }
        
        return peripherals
    }
    
    // MARK: - Private Methods
    
    
}
