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

protocol ButtonlessDFUProtocol: GATTProfileCharacteristic, RawRepresentable {
    
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
