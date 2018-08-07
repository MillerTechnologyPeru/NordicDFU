//
//  GATTProfile.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation
import Bluetooth
import GATT

/// GATT Profile
public protocol GATTProfile {
    
    static var services: [GATTProfileService.Type] { get }
}

/// GATT Service
public protocol GATTProfileService {
    
    static var uuid: BluetoothUUID { get }
    
    static var isPrimary: Bool { get }
    
    static var characteristics: [GATTProfileCharacteristic.Type] { get }
}

/// GATT Service Characteristic
public protocol GATTProfileCharacteristic {
    
    static var service: GATTProfileService.Type { get }
    
    static var uuid: BluetoothUUID { get }
        
    init?(data: Data)
    
    var data: Data { get }
}

// MARK: - Extensions

internal extension CentralProtocol {
    
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
