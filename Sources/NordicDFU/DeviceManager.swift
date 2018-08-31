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
