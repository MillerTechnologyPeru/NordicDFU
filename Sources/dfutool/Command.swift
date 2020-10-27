//
//  Command.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/31/18.
//

import Foundation
import GATT
import NordicDFU

public enum CommandType: String {
    
    /// Scan for nearby devices.
    case scan
    
    /// Enter DFU Mode / Bootloader
    case enterBootloader = "dfu"
    
    /// Configure Network
    case uploadFirmware = "upload"
}

public enum Command {
    
    case scan(ScanCommand)
    case enterBootloader(EnterBootloaderCommand)
    case uploadFirmware(UploadFirmwareCommand)
}

public extension Command {
    
    func execute <Central: CentralProtocol> (_ deviceManager: NordicDeviceManager<Central>) throws {
        
        switch self {
            case let .scan(command):
                try command.execute(deviceManager)
            case let .enterBootloader(command):
                try command.execute(deviceManager)
            case let .uploadFirmware(command):
                try command.execute(deviceManager)
        }
    }
}

public protocol CommandProtocol {
    
    static var commandType: CommandType { get }
    
    func execute <Central: CentralProtocol> (_ deviceManager: NordicDeviceManager<Central>) throws
}

public protocol ArgumentableCommand: CommandProtocol {
    
    associatedtype Option: OptionProtocol
    
    init(parameters: [Parameter<Option>]) throws
}

public extension ArgumentableCommand {
    
    init(arguments: [String]) throws {
        
        let parameters = try Parameter<Option>.parse(arguments: arguments)
        
        try self.init(parameters: parameters)
    }
}

public extension Command {
    
    init(arguments: [String]) throws {
        
        guard let commandTypeString = arguments.first
            else { throw CommandError.noCommand }
        
        guard let commandType = CommandType(rawValue: commandTypeString)
            else { throw CommandError.invalidCommandType(commandTypeString) }
        
        let commandArguments = Array(arguments.dropFirst())
        
        switch commandType {
        case .scan:
            let command = try ScanCommand(arguments: commandArguments)
            self = .scan(command)
        case .enterBootloader:
            let command = try EnterBootloaderCommand(arguments: commandArguments)
            self = .enterBootloader(command)
        case .uploadFirmware:
            let command = try UploadFirmwareCommand(arguments: commandArguments)
            self = .uploadFirmware(command)
        }
    }
}
