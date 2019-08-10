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
        
    @Binding(getValue: { Preferences.shared.timeout.value },
             setValue: { Preferences.shared.timeout.value = $0 })
    public var timeout: TimeInterval
    
    @Binding(getValue: { Preferences.shared.writeWithoutResponseTimeout.value },
             setValue: { Preferences.shared.writeWithoutResponseTimeout.value = $0 })
    public var writeWithoutResponseTimeout: TimeInterval
    
    @Binding(getValue: { Float(Preferences.shared.packetReceiptNotification.value) },
             setValue: { Preferences.shared.packetReceiptNotification.value = UInt16($0) })
    public var packetReceiptNotification: Float
    
    @Binding(getValue: { Preferences.shared.showPowerAlert.value },
             setValue: { Preferences.shared.showPowerAlert.value = $0 })
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
    }
    
    public var timeout = CurrentValueSubject<TimeInterval, Never>(30.0)
    
    //@UserDefault("writeWithoutResponseTimeout", defaultValue: 3)
    public var writeWithoutResponseTimeout = CurrentValueSubject<TimeInterval, Never>(3.0) // : TimeInterval = 3.0
    
    public var packetReceiptNotification = CurrentValueSubject<UInt16, Never>(12)
    
    public var showPowerAlert = CurrentValueSubject<Bool, Never>(false)
}

@available(iOS 13.0, *)
internal extension Preferences {
    
    enum Key: String {
        
        case timeout
        case writeWithoutResponseTimeout
        case packetReceiptNotification
        case showPowerAlert
    }
    
    subscript (key: Key) -> Any? {
        
        get { userDefaults.object(forKey: key.rawValue) }
        set { userDefaults.set(newValue, forKey: key.rawValue) }
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
