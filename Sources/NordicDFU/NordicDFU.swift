//
//  NordicDFU.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

public protocol NordicGATTProfile: GATTProfile {
    
    //func start()
}

/// Nordic Legacy DFU profile
public struct NordicLegacyDFUProfile: NordicGATTProfile {
    
    public static let services: [GATTProfileService.Type] = [
        DFUService.self
    ]
    
    
}
