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

fileprivate extension GATTConnectionCache {
    
    enum ButtonlessDFUCharacteristic {
        
        case experimental(ButtonlessDFUExperimental)
        case withBondSharing(ButtonlessDFUWithBondSharing)
        case withoutBondSharing(ButtonlessDFUWithoutBondSharing)
    }
    
    func buttonlessDFUCharacteristic(_ rawValue: ButtonlessDFUValue) throws -> (Characteristic<Peripheral>, ButtonlessDFUProtocol.Type) {
        
        let characteristicTypes: [ButtonlessDFUProtocol.Type] = [
            ButtonlessDFUExperimental.self,
            ButtonlessDFUWithBondSharing.self,
            ButtonlessDFUWithoutBondSharing.self
        ]
        
        // find buttonless DFU DFU characteristic
        // only 1 should be present, but there are 3 variations (experimental, with bond, without bond)
        
        for characteristicType in characteristicTypes {
            
            guard let characteristic = self.characteristics.first(where: { $0.uuid == characteristicType.uuid })
                else { continue }
            
            return (characteristic, characteristicType)
        }
        
        throw CentralError.invalidAttribute(characteristicTypes[0].uuid)
    }
}

internal extension CentralProtocol {
    
    func buttonlessDFU(_ request: ButtonlessDFURequest,
                       for cache: GATTConnectionCache<Peripheral>,
                       timeout: Timeout) throws {
        
        let (foundCharacteristic, buttonlessDFU) = try cache.buttonlessDFUCharacteristic()
        
        var notificationValue: ErrorValue<ButtonlessDFUResponse>?
        
        try self.notify(buttonlessDFU, for: foundCharacteristic, timeout: timeout, notification: { notificationValue = $0 })
        
        // send request
        try self.write(buttonlessDFU.init(rawValue: .request(request)),
                       for: cache,
                       timeout: timeout)
        
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
                
                // stop notifications
                try self.notify(DFUControlPoint.self, for: cache, timeout: timeout, notification: nil)
                
                switch value {
                    
                case let .response(response):
                    
                    if let error = response.error {
                        
                        throw error
                        
                    } else {
                        
                        guard response.request == T.opcode
                            else { throw NordicGATTError.invalidData(response.data) }
                        
                        // success
                        return
                    }
                    
                default:
                    
                    throw NordicGATTError.invalidData(value.data)
                }
                
            }
            
        } while true // keep waiting
    }
}

fileprivate extension CentralProtocol {
    
    func notify(_ characteristicType: ButtonlessDFUProtocol.Type,
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
