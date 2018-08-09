//
//  NordicDFU.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation
import Bluetooth
import GATT

public protocol NordicGATTProfile: GATTProfile {
    
    //func start()
}

/// Nordic Legacy DFU profile
public struct NordicLegacyDFUProfile: NordicGATTProfile {
    
    public static let services: [GATTProfileService.Type] = [
        DFUService.self
    ]
    
    func start <Central: CentralProtocol> (peripheral: Central.Peripheral, central: Central) throws {
        
        //try central.send(DFUStartRequest(firmwareType: <#T##DFUFirmwareType#>), for: <#T##[Characteristic<Peer>]#>, timeout: <#T##Timeout#>)
    }
}
