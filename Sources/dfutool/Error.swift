//
//  Error.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/31/18.
//

import Foundation
import NordicDFU

public enum CommandError: Error {
    
    /// Bluetooth controllers not availible.
    case bluetoothUnavailible
    
    /// No command specified.
    case noCommand

    /// Device not found
    case notFound(String)
    
    /// Invalid command.
    case invalidCommandType(String)
    
    case invalidOption(String)
    
    case missingOption(String)
    
    case optionMissingValue(String)
    
    case invalidOptionValue(option: String, value: String)
}
