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
        
    @ObjectBinding
    var timeout = Bind(Preferences.shared, keyPath: \.timeout)
    
    @ObjectBinding
    var writeWithoutResponseTimeout = Bind(Preferences.shared, keyPath: \.writeWithoutResponseTimeout)
    
    @ObjectBinding
    var packetReceiptNotification = Bind(Preferences.shared, keyPath: \.packetReceiptNotification)
    
    @ObjectBinding
    var showPowerAlert = Bind(Preferences.shared, keyPath: \.showPowerAlert)
    
    // MARK: - View
    
    var body: some View {
        List {
            SliderCell(
                title: Text("Timeout"),
                value: timeout.binding,
                from: 1.0,
                through: 30.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            SliderCell(
                title: Text("Write without Response Timeout"),
                value: writeWithoutResponseTimeout.binding,
                from: 1.0,
                through: 30.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            /*
            SliderCell(
                title: Text("Packet Reciept Notification"),
                value: packetReceiptNotification.binding,
                from: 0.0,
                through: 25.0,
                by: 1.0,
                text: { $0 > 0 ? Text(verbatim: "\(Int($0))") : Text("Disabled") }
            )*/
            Toggle("Show Power Alert", isOn: showPowerAlert.binding)
        }
    }
}

@available(iOS 13, *)
extension SettingsView {
    
    final class Bind <Root, Value> : BindableObject, BindingConvertible {
        
        var root: Root
        let keyPath: WritableKeyPath<Root, Value>
        let willChange = PassthroughSubject<Bind<Root, Value>, Never>()
        
        init(_ root: Root, keyPath: WritableKeyPath<Root, Value>) {
            self.root = root
            self.keyPath = keyPath
        }
        
        var binding: Binding<Value> {
            return Binding(
                getValue: { self.root[keyPath: self.keyPath] },
                setValue: {
                    self.root[keyPath: self.keyPath] = $0
                    self.willChange.send(self)
                }
            )
        }
    }
    /*
    final class ViewModel: BindableObject {
        
        let preferences: Preferences
        
        var willChange = PassthroughSubject<ViewModel, Never>()
        
        init(preferences: Preferences = .shared) {
            self.preferences = preferences
        }
        
        var timeout: TimeInterval
        
        var writeWithoutResponseTimeout: TimeInterval {
            get { preferences.writeWithoutResponseTimeout }
            set {
                preferences.writeWithoutResponseTimeout = newValue
                willChange.send(self)
            }
        }
        
        var packetReceiptNotification: Double {
            get { .init(preferences.writeWithoutResponseTimeout) }
            set {
                preferences.writeWithoutResponseTimeout = .init(newValue)
                willChange.send(self)
            }
        }
        
        var showPowerAlert: Bool {
            get { preferences.showPowerAlert }
            set {
                preferences.showPowerAlert = newValue
                willChange.send(self)
            }
        }
    }*/
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
            VStack {
                Spacer(minLength: 8)
                HStack {
                    title.lineLimit(2)
                    Spacer(minLength: 20)
                    text(value.value)
                }
                Slider(value: value, from: from, through: through, by: by)
            }
        }
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
