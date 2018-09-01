//
//  EnterBootloaderCommand.swift
//  dfutool
//
//  Created by Alsey Coleman Miller on 9/1/18.
//

import Foundation
import GATT
import NordicDFU

#if os(macOS)
import DarwinGATT
#endif

public struct EnterBootloaderCommand: DeviceCommand {
    
    // MARK: - Properties
    
    public static let commandType: CommandType = .enterBootloader
    
    public let peripheral: String
    
    public var scanTimeout: TimeInterval
    
    public var filterDuplicates: Bool
    
    public var timeout: TimeInterval
    
    public init(parameters: [Parameter<Option>]) throws {
        
        guard let deviceIdentifierString = parameters.first(where: { $0.option == .peripheral })?.value
            else { throw CommandError.missingOption(Option.scanTimeout.rawValue) }
        
        self.peripheral = deviceIdentifierString
        
        if let stringValue = parameters.first(where: { $0.option == .scanTimeout })?.value {
            
            guard let timeInterval = TimeInterval(stringValue)
                else { throw CommandError.invalidOptionValue(option: Option.scanTimeout.rawValue, value: stringValue) }
            
            self.scanTimeout = timeInterval
            
        } else {
            
            self.scanTimeout = 10
        }
        
        if let stringValue = parameters.first(where: { $0.option == .filterDuplicates })?.value {
            
            guard let value = CommandLineBool(rawValue: stringValue)
                else { throw CommandError.invalidOptionValue(option: Option.filterDuplicates.rawValue, value: stringValue) }
            
            self.filterDuplicates = value.boolValue
            
        } else {
            
            self.filterDuplicates = false
        }
        
        if let stringValue = parameters.first(where: { $0.option == .timeout })?.value {
            
            guard let timeout = TimeInterval(stringValue)
                else { throw CommandError.invalidOptionValue(option: Option.timeout.rawValue, value: stringValue) }
            
            self.timeout = timeout
            
        } else {
            
            self.timeout = .gattDefaultTimeout
        }
    }
    
    public func execute <Central: CentralProtocol> (_ deviceManager: NordicDeviceManager<Central>) throws {
        
        
    }
}

public extension EnterBootloaderCommand {
    
    public enum Option: String, OptionProtocol {
        
        case peripheral
        case scanTimeout
        case filterDuplicates = "filter"
        case timeout
        
        public static let all: Set<Option> = [.peripheral,
                                              .scanTimeout,
                                              .filterDuplicates,
                                              .timeout]
    }
}
