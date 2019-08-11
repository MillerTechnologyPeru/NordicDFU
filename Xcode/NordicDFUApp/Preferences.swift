//
//  Preferences.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 8/10/19.
//  Copyright © 2019 PureSwift. All rights reserved.
//

import Foundation

/// Preferences
public final class Preferences {
    
    public static let shared = Preferences()
    
    internal let userDefaults: UserDefaults
    
    public var didChange: ((Key) -> ())?
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    private subscript <T> (key: Key) -> T? {
        get { userDefaults.value(forKey: key.rawValue) as? T }
        set {
            userDefaults.set(newValue, forKey: key.rawValue)
            didChange?(key)
        }
    }
}

public extension Preferences {
    
    var timeout: TimeInterval {
        get { return self[.timeout] ?? 30.0 }
        set { self[.timeout] = newValue }
    }
    
    var scanDuration: TimeInterval {
        get { return self[.scanDuration] ?? 5.0 }
        set { self[.scanDuration] = newValue }
    }
    
    var filterDuplicates: Bool {
        get { return self[.filterDuplicates] ?? true }
        set { self[.filterDuplicates] = newValue }
    }
    
    var writeWithoutResponseTimeout: TimeInterval {
        get { return self[.writeWithoutResponseTimeout] ?? 3.0 }
        set { self[.writeWithoutResponseTimeout] = newValue }
    }
    
    var packetReceiptNotification: UInt16 {
        get { return self[.packetReceiptNotification] ?? 12 }
        set { self[.packetReceiptNotification] = newValue }
    }
    
    var showPowerAlert: Bool {
        get { return self[.showPowerAlert] ?? false }
        set { self[.showPowerAlert] = newValue }
    }
    
    var devicesFilter: String {
        get { return self[.devicesFilter] ?? "" }
        set { self[.devicesFilter] = newValue }
    }
}

public extension Preferences {
    
    enum Key: String, CaseIterable {
        
        case timeout
        case filterDuplicates
        case showPowerAlert
        case writeWithoutResponseTimeout
        case packetReceiptNotification
        case scanDuration
        case devicesFilter
    }
}
