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
    
    @ObservedObject
    var preferences: Preferences = .shared
    
    // MARK: - View
    
    var body: some View {
        List {
            SliderCell(
                title: Text(verbatim: "Scan Duration"),
                value: $preferences.scanDuration,
                from: 1.0,
                through: 10.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            SliderCell(
                title: Text("Timeout"),
                value: $preferences.timeout,
                from: 1.0,
                through: 30.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            SliderCell(
                title: Text("Write without Response Timeout"),
                value: $preferences.writeWithoutResponseTimeout,
                from: 1.0,
                through: 30.0,
                by: 0.1,
                text: { Text(verbatim: "\(String(format: "%.1f", $0))s") }
            )
            SliderCell(
                title: Text("Packet Reciept Notification"),
                value: Binding(
                    get: { .init(self.preferences.packetReceiptNotification) },
                    set: { self.preferences.packetReceiptNotification = .init($0) }
                ),
                from: 0.0,
                through: 25.0,
                by: 1.0,
                text: { $0 > 0 ? Text(verbatim: "\(Int($0))") : Text("Disabled") }
            )
            Toggle("Show Power Alert", isOn: $preferences.showPowerAlert)
            Toggle("Filter Duplicates", isOn: $preferences.filterDuplicates)
        }
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
                Slider(value: value, in: from ... through, step: by)
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
