//
//  ScanCommand.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/31/18.
//

import Foundation
import GATT
import NordicDFU

public struct ScanCommand: ArgumentableCommand {
    
    // MARK: - Properties
    
    public static let commandType: CommandType = .scan
    
    public var duration: TimeInterval
    
    public var filterDuplicates: Bool
    
    public var timeout: TimeInterval
    
    // MARK: - Initialization
    
    public static let `default` = ScanCommand()
    
    public init(duration: TimeInterval = 5.0,
                filterDuplicates: Bool = false,
                timeout: TimeInterval = .gattDefaultTimeout) {
        
        self.duration = duration
        self.filterDuplicates = filterDuplicates
        self.timeout = timeout
    }
    
    public init(parameters: [Parameter<Option>]) throws {
        
        if let durationString = parameters.first(where: { $0.option == .duration })?.value {
            
            guard let duration = TimeInterval(durationString)
                else { throw CommandError.invalidOptionValue(option: Option.duration.rawValue, value: durationString) }
            
            self.duration = duration
            
        } else {
            
            self.duration = type(of: self).default.duration
        }
        
        if let stringValue = parameters.first(where: { $0.option == .filterDuplicates })?.value {
            
            guard let value = CommandLineBool(rawValue: stringValue)
                else { throw CommandError.invalidOptionValue(option: Option.filterDuplicates.rawValue, value: stringValue) }
            
            self.filterDuplicates = value.boolValue
            
        } else {
            
            self.filterDuplicates = type(of: self).default.filterDuplicates
        }
        
        if let stringValue = parameters.first(where: { $0.option == .timeout })?.value {
            
            guard let timeout = TimeInterval(stringValue)
                else { throw CommandError.invalidOptionValue(option: Option.timeout.rawValue, value: stringValue) }
            
            self.timeout = timeout
            
        } else {
            
            self.timeout = type(of: self).default.timeout
        }
    }
    
    // MARK: - Methods
    
    /// Scans for nearby devices.
    public func execute <Central: CentralProtocol> (_ deviceManager: NordicDeviceManager<Central>) throws {
        
        print("Scanning for \(duration) seconds...")
        
        var devices = Set<Central.Peripheral>()
        
        try deviceManager.scan(duration: duration, timeout: timeout) {
            
            devices.insert($0.peripheral)
            
            let deviceInformation = "[\($0.peripheral)] \($0.type) \($0.mode)"
            
            print(deviceInformation)
        }
    }
}

public extension ScanCommand {
    
    public enum Option: String, OptionProtocol {
        
        case duration
        case filterDuplicates = "filter"
        case timeout
        
        public static let all: Set<Option> = [.duration,
                                              .filterDuplicates,
                                              .timeout]
    }
}
