//
//  UploadFirmwareCommand.swift
//  dfutool
//
//  Created by Alsey Coleman Miller on 9/1/18.
//

import Foundation
import GATT
import NordicDFU

public struct UploadFirmwareCommand: DeviceCommand {
    
    // MARK: - Properties
    
    public static let commandType: CommandType = .uploadFirmware
    
    public let peripheral: String
    
    public var scanDuration: TimeInterval
    
    public var filterDuplicates: Bool
    
    public var timeout: TimeInterval
    
    public var firmwarePath: String
    
    public init(parameters: [Parameter<Option>]) throws {
        
        guard let deviceIdentifierString = parameters.first(where: { $0.option == .peripheral })?.value
            else { throw CommandError.missingOption(Option.peripheral.rawValue) }
        
        self.peripheral = deviceIdentifierString
        
        guard let firmwarePath = parameters.first(where: { $0.option == .firmware })?.value
            else { throw CommandError.missingOption(Option.firmware.rawValue) }
        
        self.firmwarePath = firmwarePath
        
        if let stringValue = parameters.first(where: { $0.option == .scanDuration })?.value {
            
            guard let timeInterval = TimeInterval(stringValue)
                else { throw CommandError.invalidOptionValue(option: Option.scanDuration.rawValue, value: stringValue) }
            
            self.scanDuration = timeInterval
            
        } else {
            
            self.scanDuration = type(of: self).defaultScanDuration
        }
        
        if let stringValue = parameters.first(where: { $0.option == .filterDuplicates })?.value {
            
            guard let value = CommandLineBool(rawValue: stringValue)
                else { throw CommandError.invalidOptionValue(option: Option.filterDuplicates.rawValue, value: stringValue) }
            
            self.filterDuplicates = value.boolValue
            
        } else {
            
            self.filterDuplicates = type(of: self).defaultFilterDuplicates
        }
        
        if let stringValue = parameters.first(where: { $0.option == .timeout })?.value {
            
            guard let timeout = TimeInterval(stringValue)
                else { throw CommandError.invalidOptionValue(option: Option.timeout.rawValue, value: stringValue) }
            
            self.timeout = timeout
            
        } else {
            
            self.timeout = type(of: self).defaultTimeout
        }
    }
    
    public func execute <Central: CentralProtocol> (_ deviceManager: NordicDeviceManager<Central>) throws {
        
        let zip = try DFUStreamZip(url: URL(fileURLWithPath: firmwarePath))
        
        let device = try scan(deviceManager)
        
        try deviceManager.uploadFirmware(zip.firmware, for: device.peripheral, timeout: timeout)
        
        print("Successfully uploaded firmware")
    }
}

public extension UploadFirmwareCommand {
    
    public enum Option: String, OptionProtocol {
        
        case peripheral
        case scanDuration = "scan"
        case filterDuplicates = "filter"
        case timeout
        case firmware
        
        public static let all: Set<Option> = [.peripheral,
                                              .scanDuration,
                                              .filterDuplicates,
                                              .timeout,
                                              .firmware]
    }
}
