//
//  Central.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation
import Bluetooth
import GATT

internal extension CentralProtocol {
    
    /// Connects to the device, fetches the data, performs the action, and disconnects.
    func device <T> (for peripheral: Peripheral,
                     filterServices: [BluetoothUUID] = [],
                     timeout: Timeout,
                     _ action: (GATTConnectionCache<Peripheral>) throws -> (T)) throws -> T {
        
        // connect first
        try connect(to: peripheral, timeout: try timeout.timeRemaining())
        
        // disconnect
        defer { disconnect(peripheral: peripheral) }
        
        var cache = GATTConnectionCache<Peripheral>()
        
        let foundServices = try discoverServices([], for: peripheral, timeout: try timeout.timeRemaining())
        
        let services: [Service<Peripheral>]
        
        if filterServices.isEmpty {
            
            services = foundServices
            
        } else {
            
            services = foundServices.filter { filterServices.contains($0.uuid) }
        }
        
        for service in services {
            
            // validate characteristic exists
            let foundCharacteristics = try discoverCharacteristics([], for: service, timeout: try timeout.timeRemaining())
            
            cache.characteristics += foundCharacteristics
        }
        
        // perform action
        return try action(cache)
    }
    
    func write <T: GATTProfileCharacteristic> (_ characteristic: T,
                                        for cache: GATTConnectionCache<Peripheral>,
                                        withResponse response: Bool = true,
                                        timeout: Timeout) throws {
        
        guard let foundCharacteristic = cache.characteristics.first(where: { $0.uuid == T.uuid })
            else { throw CentralError.invalidAttribute(T.uuid) }
        
        try self.write(characteristic, for: foundCharacteristic, timeout: timeout)
    }
    
    func write <T: GATTProfileCharacteristic> (_ characteristic: T,
                                        for foundCharacteristic: Characteristic<Peripheral>,
                                        withResponse response: Bool = true,
                                        timeout: Timeout) throws {
        
        try self.writeValue(characteristic.data,
                            for: foundCharacteristic,
                            withResponse: response,
                            timeout: try timeout.timeRemaining())
    }
    
    func read <T: GATTProfileCharacteristic> (_ characteristic: T.Type,
                                       for cache: GATTConnectionCache<Peripheral>,
                                       timeout: Timeout) throws -> T {
        
        guard let foundCharacteristic = cache.characteristics.first(where: { $0.uuid == T.uuid })
            else { throw CentralError.invalidAttribute(T.uuid) }
        
        let data = try self.readValue(for: foundCharacteristic,
                                      timeout: try timeout.timeRemaining())
        
        guard let value = T.init(data: data)
            else { throw GATTError.invalidData(data) }
        
        return value
    }
    
    func notify <T: GATTProfileCharacteristic> (_ characteristic: T.Type,
                                         for cache: GATTConnectionCache<Peripheral>,
                                         timeout: Timeout,
                                         notification: ((ErrorValue<T>) -> ())?) throws {
        
        guard let foundCharacteristic = cache.characteristics.first(where: { $0.uuid == T.uuid })
            else { throw CentralError.invalidAttribute(T.uuid) }
        
        try notify(characteristic, for: foundCharacteristic, timeout: timeout, notification: notification)
    }
    
    func notify <T: GATTProfileCharacteristic> (_ characteristic: T.Type,
                                         for foundCharacteristic: Characteristic<Peripheral>,
                                         timeout: Timeout,
                                         notification: ((ErrorValue<T>) -> ())?) throws {
        
        let dataNotification: ((Data) -> ())?
        
        if let notification = notification {
            
            dataNotification = { (data) in
                
                let response: ErrorValue<T>
                
                if let value = T.init(data: data) {
                    
                    response = .value(value)
                    
                } else {
                    
                    response = .error(GATTError.invalidData(data))
                }
                
                notification(response)
            }
            
        } else {
            
            dataNotification = nil
        }
        
        try notify(dataNotification, for: foundCharacteristic, timeout: try timeout.timeRemaining())
    }
}

// MARK: - Supporting Types

/// Basic wrapper for error / value pairs.
internal enum ErrorValue <T> {
    
    case error(Error)
    case value(T)
}

/// GATT Connection Cache
internal struct GATTConnectionCache <Peripheral: Peer> {
    
    fileprivate init() {
        
        self.characteristics = []
    }
    
    fileprivate(set) var characteristics: [Characteristic<Peripheral>]
}

// GATT timeout
internal struct Timeout {
    
    let start: Date
    
    let timeout: TimeInterval
    
    var end: Date {
        
        return start + timeout
    }
    
    init(start: Date = Date(),
         timeout: TimeInterval) {
        
        self.start = start
        self.timeout = timeout
    }
    
    @discardableResult
    func timeRemaining(for date: Date = Date()) throws -> TimeInterval {
        
        let remaining = end.timeIntervalSince(date)
        
        if remaining > 0 {
            
            return remaining
            
        } else {
            
            throw CentralError.timeout
        }
    }
}
