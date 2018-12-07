//
//  Central.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 12/6/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import Bluetooth
import GATT
import NordicDFU

#if os(iOS)

import DarwinGATT

typealias NativeCentral = DarwinCentral

private enum CentralCache {
    
    static let options = DarwinCentral.Options(showPowerAlert: false, restoreIdentifier: nil)
    
    static let central = DarwinCentral(options: options)
}

#elseif os(Android) || os(macOS)

import Android
import AndroidBluetooth
import AndroidUIKit

typealias NativeCentral = AndroidCentral

private enum CentralCache {
    
    static let hostController = Android.Bluetooth.Adapter.default!
    
    static let context = UIApplication.shared.androidActivity
    
    static let options = AndroidCentral.Options()
    
    static let central = AndroidCentral(hostController: hostController, context: context, options: options)
}

#endif

private extension CentralCache {
    
    static let deviceManager = NordicDeviceManager(central: central)
}

internal extension NativeCentral {
    
    static var shared: NativeCentral {
        
        return CentralCache.central
    }
}

internal extension NordicDeviceManager {
    
    static var shared: NordicDeviceManager<NativeCentral> {
        
        return CentralCache.deviceManager
    }
}

internal typealias DeviceManager = NordicDeviceManager<NativeCentral>
