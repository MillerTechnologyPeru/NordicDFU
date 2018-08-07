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
                             characteristics: [GATTProfileCharacteristic.Type],
                             timeout: Timeout,
                             _ action: ([Characteristic<Peripheral>]) throws -> (T)) throws -> T {
        
        // connect first
        try connect(to: peripheral, timeout: try timeout.timeRemaining())
        
        // disconnect
        defer { disconnect(peripheral: peripheral) }
        
        let foundCharacteristics = try self.characteristics(characteristics,
                                                            for: peripheral,
                                                            timeout: timeout)
        
        // perform action
        return try action(foundCharacteristics)
    }
    
    func write <T: GATTProfileCharacteristic> (_ characteristic: T,
                                               for cache: [Characteristic<Peripheral>],
                                               withResponse response: Bool = true,
                                               timeout: Timeout) throws {
        
        guard let foundCharacteristic = cache.first(where: { $0.uuid == T.uuid })
            else { throw CentralError.invalidAttribute(T.uuid) }
        
        try self.writeValue(characteristic.data,
                               for: foundCharacteristic,
                               withResponse: response,
                               timeout: try timeout.timeRemaining())
    }
    
    func read <T: GATTProfileCharacteristic> (_ characteristic: T.Type,
                                                      for cache: [Characteristic<Peripheral>],
                                                      timeout: Timeout) throws -> T {
        
        guard let foundCharacteristic = cache.first(where: { $0.uuid == T.uuid })
            else { throw CentralError.invalidAttribute(T.uuid) }
        
        let data = try self.readValue(for: foundCharacteristic,
                                         timeout: try timeout.timeRemaining())
        
        guard let value = T.init(data: data)
            else { throw NordicGATTError.invalidData(data) }
        
        return value
    }
    
    func notify <T: GATTProfileCharacteristic> (_ characteristic: T.Type,
                                                for cache: [Characteristic<Peripheral>],
                                                timeout: Timeout,
                                                notification: ((GATTProfileNotification<T>) -> ())?) throws {
        
        guard let foundCharacteristic = cache.first(where: { $0.uuid == T.uuid })
            else { throw CentralError.invalidAttribute(T.uuid) }
        
        let dataNotification: ((Data) -> ())?
        
        if let notification = notification {
            
            dataNotification = { (data) in
                
                let response: GATTProfileNotification<T>
                
                if let value = T.init(data: data) {
                    
                    response = .value(value)
                    
                } else {
                    
                    response = .invalid(data)
                }
                
                notification(response)
            }
            
        } else {
            
            dataNotification = nil
        }
        
        try notify(dataNotification, for: foundCharacteristic, timeout: try timeout.timeRemaining())
    }
    
    /// Verify a peripheral declares the GATT profile.
    func characteristics(_ characteristics: [GATTProfileCharacteristic.Type],
                         for peripheral: Peripheral,
                         timeout: Timeout) throws -> [Characteristic<Peripheral>] {
        
        // group characteristics by service
        var characteristicsByService = [BluetoothUUID: [BluetoothUUID]]()
        characteristics.forEach {
            characteristicsByService[$0.service.uuid] = (characteristicsByService[$0.service.uuid] ?? []) + [$0.uuid]
        }
        
        var results = [Characteristic<Peripheral>]()
        
        // validate required characteristics
        let foundServices = try discoverServices([], for: peripheral, timeout: try timeout.timeRemaining())
        
        for (serviceUUID, characteristics) in characteristicsByService {
            
            // validate service exists
            guard let service = foundServices.first(where: { $0.uuid == serviceUUID })
                else { throw NordicGATTError.serviceNotFound(serviceUUID) }
            
            // validate characteristic exists
            let foundCharacteristics = try discoverCharacteristics([], for: service, timeout: try timeout.timeRemaining())
            
            for characteristicUUID in characteristics {
                
                guard let characteristic = foundCharacteristics.first(where: { $0.uuid == characteristicUUID })
                    else { throw NordicGATTError.characteristicNotFound(characteristicUUID) }
                
                results.append(characteristic)
            }
        }
        
        assert(results.count == characteristics.count)
        
        return results
    }
}

internal enum GATTProfileNotification <T: GATTProfileCharacteristic> {
    
    case invalid(Data)
    case value(T)
}
