//
//  SettingsView.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 8/9/19.
//  Copyright © 2019 PureSwift. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 13, *)
struct SettingsView: View {
    
    // MARK: - Properties
        
    @Binding(getValue: { Preferences.shared.timeout },
             setValue: { Preferences.shared.timeout = $0 })
    public var timeout: TimeInterval
    
    @Binding(getValue: { Preferences.shared.writeWithoutResponseTimeout },
             setValue: { Preferences.shared.writeWithoutResponseTimeout = $0 })
    public var writeWithoutResponseTimeout: TimeInterval
    
    @Binding(getValue: { Float(Preferences.shared.packetReceiptNotification) },
             setValue: { Preferences.shared.packetReceiptNotification = UInt16($0) })
    public var packetReceiptNotification: Float
    
    @Binding(getValue: { Preferences.shared.showPowerAlert },
             setValue: { Preferences.shared.showPowerAlert = $0 })
    public var showPowerAlert: Bool
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            List {
                Slider(value: $timeout, from: 1.0, through: 30.0, by: 0.1)
                Slider(value: $writeWithoutResponseTimeout, from: 1.0, through: 30.0, by: 0.1)
                Slider(value: $packetReceiptNotification, from: 0.0, through: 22.0, by: 1.0)
                Toggle("Show Power Alert", isOn: $showPowerAlert)
            }
            navigationBarTitle(Text("Settings"), displayMode: .large)
        }
    }
}

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
}

@available(iOS 13.0, *)
internal extension Preferences {
    
    enum Key: String {
        
        case timeout
        case writeWithoutResponseTimeout
        case packetReceiptNotification
        case showPowerAlert
    }
}

@available(iOS 13.0, *)
internal extension UserDefault {
    
    init(_ key: Preferences.Key,
         defaultValue: Value,
         userDefaults: UserDefaults = .standard) {
        
        self.key = key.rawValue
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
}

#if DEBUG
@available(iOS 13, *)
extension SettingsView: PreviewProvider {

    static var previews: some View {
        return SettingsView()
    }
}
#endif
