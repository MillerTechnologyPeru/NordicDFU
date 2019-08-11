//
//  Store.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 8/10/19.
//  Copyright © 2019 PureSwift. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import NordicDFU
import DarwinGATT

@available(iOS 13.0, *)
final class Store: BindableObject {
        
    // MARK: - Initialization
    
    static let shared = Store()
    
    init(deviceManager: DeviceManager = .shared,
         preferences: Preferences = .shared) {
        
        self.deviceManager = deviceManager
        self.preferences = preferences
        
        // configure central
        self.deviceManager.central.stateChanged = { [weak self] in
            guard let self = self else { return }
            self.willChange.send(self)
            self.log?("Bluetooth State changed: \($0)")
            if $0 == .poweredOn {
                //scan()
            }
        }
        
        // configure preferences
        self.preferences.didChange = { [weak self] in
            guard let self = self else { return }
            self.preferencesChanged(key: $0)
        }
        self.applyPreferences()
    }
    
    // MARK: - Properties
    
    let willChange = PassthroughSubject<Store, Never>()
    
    var log: ((String) -> ())?
    
    let deviceManager: DeviceManager
    
    let preferences: Preferences
    
    private let queue = DispatchQueue(label: "Store Queue")
    
    // MARK: - Methods
    
    private func applyPreferences() {
        Preferences.Key.allCases.forEach {
            self.preferencesChanged(key: $0)
        }
    }
    
    private func preferencesChanged(key: Preferences.Key) {
        
        // inform observers
        self.willChange.send(self)
        
        switch key {
        case .showPowerAlert:
            break //deviceManager.central.options.showPowerAlert = preferences.showPowerAlert
        case .packetReceiptNotification:
            deviceManager.packetReceiptNotification.rawValue = preferences.packetReceiptNotification
        case .writeWithoutResponseTimeout:
            deviceManager.central.writeWithoutResponseTimeout = preferences.writeWithoutResponseTimeout
        case .timeout:
            break
        case .devicesFilter:
            break
        case .filterDuplicates:
            break
        case .scanDuration:
            break
        }
    }
}
