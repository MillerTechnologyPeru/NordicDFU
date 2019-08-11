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
            print("Bluetooth State changed: \($0)")
            if $0 == .poweredOn {
                //scan()
            }
        }
    }
    
    // MARK: - Properties
    
    let willChange = PassthroughSubject<Store, Never>()
    
    let deviceManager: DeviceManager
    
    let preferences: Preferences
    
    private let queue = DispatchQueue(label: "Store Queue")
    
    
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class BindingWrapper: BindableObject {
    
    public let willChange = PassthroughSubject<Void, Never>()
    
    
}
