import Foundation
import Bluetooth
import GATT
import NordicDFU

#if os(Linux)
import BluetoothLinux
#elseif os(macOS)
import DarwinGATT
#endif

func run(arguments: [String] = CommandLine.arguments) throws {
    
    //  first argument is always the current directory
    let arguments = Array(arguments.dropFirst())
    
    // parse commands
    let command = try Command(arguments: arguments)
    
    // initialize GATT Central
    #if os(Linux)
    
    guard let hostController = HostController.default
        else { throw CommandError.bluetoothUnavailible }
    
    print("Bluetooth Controller: \(hostController.address)")
    
    let central = GATTCentral<HostController, L2CAPSocket>(hostController: hostController)
    
    central.newConnection = { (scanData, report) in
        return try L2CAPSocket.lowEnergyClient(controllerAddress: hostController.address,
                                               destination: (address: scanData.peripheral.identifier,
                                                             type: AddressType(lowEnergy: report.addressType)),
                                               securityLevel: .low)
    }
    
    #elseif os(macOS)
    
    let central = DarwinCentral()
    
    // wait till CoreBluetooth is ready
    try central.waitPowerOn()
    
    #endif
    
    let deviceManager = NordicDeviceManager(central: central)
    
    deviceManager.log = { print("DeviceManager: \($0)") }
    
    // execute command
    try command.execute(deviceManager)
}

func exit(_ error: Error) {
    
    print("Error: \(error)")
    exit(1)
}

do { try run() }
catch { exit(error) }
