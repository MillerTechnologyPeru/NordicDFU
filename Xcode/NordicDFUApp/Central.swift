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
import DarwinGATT
import NordicDFU

typealias NativeCentral = DarwinCentral

private enum CentralCache {
    
    static let options = DarwinCentral.Options(
        showPowerAlert: false,
        restoreIdentifier: nil
    )
    
    static let central = DarwinCentral(options: options)
}

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
