//
//  SettingsView.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 8/9/19.
//  Copyright © 2019 PureSwift. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

@available(iOS 13, *)
struct SettingsView: View {
    
    // MARK: - Properties
        
    //@Binding(getValue: { Preferences.shared.timeout },
    //         setValue: { Preferences.shared.timeout = $0 })
    @State
    public var timeout: TimeInterval = 30
    
    //@Binding(getValue: { Preferences.shared.writeWithoutResponseTimeout },
    //         setValue: { Preferences.shared.writeWithoutResponseTimeout = $0 })
    @State
    public var writeWithoutResponseTimeout: TimeInterval = 3
    
    //@Binding(getValue: { .init(Preferences.shared.packetReceiptNotification) },
    //         setValue: { Preferences.shared.packetReceiptNotification = .init($0) })
    @State
    public var packetReceiptNotification: Double = 12
    
    //@Binding(getValue: { Preferences.shared.showPowerAlert },
    //         setValue: { Preferences.shared.showPowerAlert = $0 })
    @State
    public var showPowerAlert: Bool = false
    
    // MARK: - View
    
    var body: some View {
        List {
            SliderCell(
                title: Text("Timeout"),
                value: $timeout,
                from: 1.0,
                through: 30.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            SliderCell(
                title: Text("Write without Response Timeout"),
                value: $writeWithoutResponseTimeout,
                from: 1.0,
                through: 30.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            SliderCell(
                title: Text("Packet Reciept Notification"),
                value: $packetReceiptNotification,
                from: 0.0,
                through: 25.0,
                by: 1.0,
                text: { $0 > 0 ? Text(verbatim: "\(Int($0))") : Text("Disabled") }
            )
            Toggle("Show Power Alert", isOn: $showPowerAlert)
        }
    }
}

@available(iOS 13, *)
extension SettingsView {
    
    struct SliderCell: View {
        
        let title: Text
        
        let value: Binding<Double>
        
        let text: (Double) -> (Text)
        
        let from: Double
        
        let through: Double
        
        let by: Double
        
        init(title: Text,
             value: Binding<Double>,
             from: Double,
             through: Double,
             by: Double = 1.0,
             text: @escaping (Double) -> (Text)) {
            
            self.title = title
            self.value = value
            self.text = text
            self.from = from
            self.through = through
            self.by = by
        }
        
        var body: some View {
            HStack {
                title.lineLimit(2)
                Spacer()
                text(value.value)
                Slider(value: value, from: from, through: through, by: by)
                    .frame(minWidth: 100, idealWidth: nil, maxWidth: nil, minHeight: nil, idealHeight: nil, maxHeight: nil, alignment: .trailing)
            }
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
