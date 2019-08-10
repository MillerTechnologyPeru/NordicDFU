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
import DarwinGATT

@available(iOS 13.0, *)
final class Store: BindableObject {
        
    // MARK: - Initialization
    
    static let shared = Store()
    
    init(central: NativeCentral = .shared,
         preferences: Preferences = .shared) {
        
        self.central = central
        self.preferences = preferences
        
        // configure central
        self.central.stateChanged = { [weak self] in
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
    
    let central: NativeCentral
    
    let preferences: Preferences
    
    private let queue = DispatchQueue(label: "Store Queue")
}
