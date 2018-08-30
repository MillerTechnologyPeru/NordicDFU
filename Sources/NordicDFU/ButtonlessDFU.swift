//
//  ButtonlessDFU.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/29/18.
//

import Foundation
import Bluetooth
import GATT

protocol ButtonlessDFUProtocol: GATTProfileCharacteristic {
    
    static var isNewAddressExpected: Bool { get }
    
    static var supportsSettingName: Bool { get }
}

public struct ButtonlessDFUWithoutBondSharing: ButtonlessDFUProtocol {
    
    public static let uuid = BluetoothUUID(rawValue: "8EC90003-F315-4F60-9FB8-838830DAEA50")!
    
    public static let properies: BitMaskOptionSet<GATT.Characteristic.Property> = [.write, .indicate]
    
    public static let service: GATTProfileService.Type = SecureDFUService.self
    
    public static let isNewAddressExpected: Bool = true
    
    public static let supportsSettingName: Bool = true
    
    public init(data: Data) {
        
        self.data = data
    }
    
    public let data: Data
}
