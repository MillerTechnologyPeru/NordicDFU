//
//  Preferences.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 8/10/19.
//  Copyright © 2019 PureSwift. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
public final class Preferences {
    
    public static let shared = Preferences()
    
    internal let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        _timeout.userDefaults = userDefaults
        _writeWithoutResponseTimeout.userDefaults = userDefaults
        _packetReceiptNotification.userDefaults = userDefaults
        _showPowerAlert.userDefaults = userDefaults
    }
    
    @UserDefault(.timeout, defaultValue: 30)
    public var timeout: TimeInterval
    
    @UserDefault(.writeWithoutResponseTimeout, defaultValue: 3)
    public var writeWithoutResponseTimeout: TimeInterval
    
    @UserDefault(.packetReceiptNotification, defaultValue: 12)
    public var packetReceiptNotification: UInt16
    
    @UserDefault(.showPowerAlert, defaultValue: false)
    public var showPowerAlert: Bool
    
    @UserDefault(.showPowerAlert, defaultValue: "")
    public var devicesFilter: String
}

@available(iOS 13.0, *)
internal extension Preferences {
    
    enum Key: String {
        
        case timeout
        case writeWithoutResponseTimeout
        case packetReceiptNotification
        case showPowerAlert
        case devicesFilter
    }
}

@available(iOS 13.0, *)
internal extension UserDefault {
    
    convenience init(_ key: Preferences.Key,
                     defaultValue: Value,
                     userDefaults: UserDefaults = .standard) {
        
        self.init(key.rawValue, defaultValue: defaultValue, userDefaults: userDefaults)
    }
}
