//
//  ButtonlessDFU.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/29/18.
//

import Foundation
import Bluetooth
import GATT

public enum ButtonlessDFUValue {
    
    case request(ButtonlessDFURequest)
    case response(ButtonlessDFUResponse)
}

public extension ButtonlessDFUValue {
    
    init?(data: Data) {
        
        guard data.isEmpty == false
            else { return nil }
        
        guard let opcode = ButtonlessDFUOpCode(rawValue: data[0])
            else { return nil }
        
        switch opcode {
            
        case .enterBootloader:
            
            self = .request(.enterBootloader)
            
        case .setName:
            
            guard let request = ButtonlessDFUSetName(data: data)
                else { return nil }
            
            self = .request(.setName(request))
            
        case .response:
            
            guard let response = ButtonlessDFUResponse(data: data)
                else { return nil }
            
            self = .response(response)
        }
    }
    
    var data: Data {
        
        switch self {
        case .request(.enterBootloader):
            return ButtonlessDFUEnterBootloader().data
        case let .request(.setName(request)):
            return request.data
        case let .response(response):
            return response.data
        }
    }
}

protocol ButtonlessDFUProtocol: GATTProfileCharacteristic /*, RawRepresentable */ {
    
    static var isNewAddressExpected: Bool { get }
    
    static var supportsSettingName: Bool { get }
    
    var rawValue: ButtonlessDFUValue { get }
    
    init(rawValue: ButtonlessDFUValue)
}

extension ButtonlessDFUProtocol {
    
    public init?(data: Data) {
        
        guard let value = ButtonlessDFUValue(data: data)
            else { return nil }
        
        self.init(rawValue: value)
    }
    
    public var data: Data {
        
        return rawValue.data
    }
}

public struct ButtonlessDFUExperimental: ButtonlessDFUProtocol {
    
    public static let uuid = BluetoothUUID(rawValue: "8E400001-F315-4F60-9FB8-838830DAEA50")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.write, .notify]
    
    public static let service: GATTProfileService.Type = SecureDFUService.self
    
    public static let isNewAddressExpected: Bool = true
    
    public static let supportsSettingName: Bool = false
    
    public let rawValue: ButtonlessDFUValue
    
    public init(rawValue: ButtonlessDFUValue) {
        
        self.rawValue = rawValue
    }
}

public struct ButtonlessDFUWithoutBondSharing: ButtonlessDFUProtocol {
    
    public static let uuid = BluetoothUUID(rawValue: "8EC90003-F315-4F60-9FB8-838830DAEA50")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.write, .indicate]
    
    public static let service: GATTProfileService.Type = SecureDFUService.self
    
    public static let isNewAddressExpected: Bool = true
    
    public static let supportsSettingName: Bool = true
    
    public let rawValue: ButtonlessDFUValue
    
    public init(rawValue: ButtonlessDFUValue) {
        
        self.rawValue = rawValue
    }
}

public struct ButtonlessDFUWithBondSharing: ButtonlessDFUProtocol {
    
    public static let uuid = BluetoothUUID(rawValue: "8EC90004-F315-4F60-9FB8-838830DAEA50")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.write, .indicate]
    
    public static let service: GATTProfileService.Type = SecureDFUService.self
    
    public static let isNewAddressExpected: Bool = false
    
    public static let supportsSettingName: Bool = false
    
    public let rawValue: ButtonlessDFUValue
    
    public init(rawValue: ButtonlessDFUValue) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Central

internal extension CentralProtocol {
    
    func buttonlessDFU(_ request: ButtonlessDFURequest,
                       for cache: GATTConnectionCache<Peripheral>,
                       timeout: Timeout) throws {
        
        let (foundCharacteristic, buttonlessDFU) = try cache.buttonlessDFUCharacteristic(.request(request))
        
        var notificationValue: ErrorValue<ButtonlessDFUResponse>?
        
        try self.notify(buttonlessDFU,
                        for: foundCharacteristic,
                        timeout: timeout) { notificationValue = $0 }
        
        // send request
        try self.writeValue(buttonlessDFU.value.data,
                            for: foundCharacteristic,
                            withResponse: true,
                            timeout: try timeout.timeRemaining())
        
        // wait for notification
        repeat {
            
            // attempt to timeout
            try timeout.timeRemaining()
            
            // get notification response
            guard let response = notificationValue
                else { usleep(100); continue }
            
            switch response {
                
            case let .error(error):
                throw error
                
            case let .value(value):
                
                if let error = value.error {
                    
                    throw error
                    
                } else {
                    
                    // success
                    return
                }
            }
            
        } while true // keep waiting
    }
}

fileprivate extension GATTConnectionCache {
    
    enum ButtonlessDFUCharacteristic {
        
        case experimental(ButtonlessDFUExperimental)
        case withBondSharing(ButtonlessDFUWithBondSharing)
        case withoutBondSharing(ButtonlessDFUWithoutBondSharing)
        
        var value: ButtonlessDFUValue {
            
            switch self {
            case let .experimental(value): return value.rawValue
            case let .withBondSharing(value): return value.rawValue
            case let .withoutBondSharing(value): return value.rawValue
            }
        }
    }
    
    func buttonlessDFUCharacteristic(_ rawValue: ButtonlessDFUValue) throws -> (Characteristic<Peripheral>, ButtonlessDFUCharacteristic) {
        
        // find buttonless DFU DFU characteristic
        // only 1 should be present, but there are 3 variations (experimental, with bond, without bond)
        
        if let characteristic = characteristics.first(where: { $0.uuid == ButtonlessDFUExperimental.uuid }) {
            
            return (characteristic, .experimental(ButtonlessDFUExperimental(rawValue: rawValue)))
            
        } else if let characteristic = characteristics.first(where: { $0.uuid == ButtonlessDFUWithBondSharing.uuid }) {
            
            return (characteristic, .withBondSharing(ButtonlessDFUWithBondSharing(rawValue: rawValue)))
            
        } else if let characteristic = characteristics.first(where: { $0.uuid == ButtonlessDFUWithoutBondSharing.uuid }) {
            
            return (characteristic, .withoutBondSharing(ButtonlessDFUWithoutBondSharing(rawValue: rawValue)))
            
        } else {
            
            throw CentralError.invalidAttribute(ButtonlessDFUExperimental.uuid)
        }
    }
}

fileprivate extension CentralProtocol {
    
    func notify(_ characteristicType: GATTConnectionCache<Peripheral>.ButtonlessDFUCharacteristic,
                for characteristic: Characteristic<Peripheral>,
                timeout: Timeout,
                notification: ((ErrorValue<ButtonlessDFUResponse>) -> ())?) throws {
        
        let dataNotification: ((Data) -> ())?
        
        if let notification = notification {
            
            dataNotification = { (data) in
                
                let response: ErrorValue<ButtonlessDFUResponse>
                
                if let value = ButtonlessDFUResponse(data: data) {
                    
                    response = .value(value)
                    
                } else {
                    
                    response = .error(GATTError.invalidData(data))
                }
                
                notification(response)
            }
            
        } else {
            
            dataNotification = nil
        }
        
        try notify(dataNotification, for: characteristic, timeout: try timeout.timeRemaining())
    }
}
