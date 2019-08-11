//
//  SettingsView.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 8/9/19.
//  Copyright © 2019 PureSwift. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

@available(iOS 13, *)
struct SettingsView: View {
    
    // MARK: - Properties
    
    @ObjectBinding
    var store: Store = .shared
    
    var scanDuration: Binding<TimeInterval> {
        Binding(store.preferences, keyPath: \.scanDuration)
    }
    
    var timeout: Binding<TimeInterval> {
        Binding(store.preferences, keyPath: \.timeout)
    }
    
    var writeWithoutResponseTimeout: Binding<TimeInterval> {
        Binding(store.preferences, keyPath: \.writeWithoutResponseTimeout)
    }
    
    var packetReceiptNotification: Binding<Double> {
        let preferences = self.store.preferences
        return .init(
            getValue: { .init(preferences.packetReceiptNotification) },
            setValue: { preferences.packetReceiptNotification = .init($0) }
        )
    }
    
    var showPowerAlert: Binding<Bool> {
        Binding(store.preferences, keyPath: \.showPowerAlert)
    }
    
    var filterDuplicates: Binding<Bool> {
        Binding(store.preferences, keyPath: \.filterDuplicates)
    }
    
    // MARK: - View
    
    var body: some View {
        List {
            SliderCell(
                title: Text("Scan Duration"),
                value: scanDuration,
                from: 1.0,
                through: 10.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            SliderCell(
                title: Text("Timeout"),
                value: timeout,
                from: 1.0,
                through: 30.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            SliderCell(
                title: Text("Write without Response Timeout"),
                value: writeWithoutResponseTimeout,
                from: 1.0,
                through: 30.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            SliderCell(
                title: Text("Packet Reciept Notification"),
                value: packetReceiptNotification,
                from: 0.0,
                through: 25.0,
                by: 1.0,
                text: { $0 > 0 ? Text(verbatim: "\(Int($0))") : Text("Disabled") }
            )
            Toggle("Show Power Alert", isOn: showPowerAlert)
            Toggle("Filter Duplicates", isOn: filterDuplicates)
        }
    }
}

@available(iOS 13.0, *)
extension Binding {
    
    init <T: AnyObject> (_ root: T, keyPath: ReferenceWritableKeyPath<T, Value>) {
        
        self.init(
            getValue: { root[keyPath: keyPath] },
            setValue: { root[keyPath: keyPath] = $0 }
        )
    }
}

// MARK: - Supporting Types

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

// MARK: - Preview

#if DEBUG
@available(iOS 13, *)
extension SettingsView: PreviewProvider {

    static var previews: some View {
        return SettingsView()
    }
}
#endif
