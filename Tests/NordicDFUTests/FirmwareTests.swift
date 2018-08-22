//
//  FirmwareTests.swift
//  NordicDFUTests
//
//  Created by Alsey Coleman Miller on 8/22/18.
//

import Foundation
import XCTest
@testable import NordicDFU

final class FirmwareTests: XCTestCase {
    
    static var allTests = [
        ("testNRF52832Application", testNRF52832Application),
        ("testNRF52832Bootloader", testNRF52832Bootloader),
        ("testNRF52832SoftdeviceBootloaderApplication", testNRF52832SoftdeviceBootloaderApplication)
        ]
    
    func testNRF52832Application() {
        
        let fileURL = URL(asset: "nrf52832_sdk_14.1_app", fileExtension: "zip")
        
        do {
            
            let zip = try DFUStreamZip(url: fileURL)
            
            guard zip.firmware.data.count == 1
                else { XCTFail("Error parsing firmware"); return }
            
            let firmwareData = zip.firmware.data[0]
            
            XCTAssertEqual(firmwareData.data.count, 39948, "Expected 40KB")
            XCTAssertEqual(firmwareData.initPacket?.count, 135)
            XCTAssertEqual(firmwareData.type, [.application])
        }
        
        catch { XCTFail("\(error)"); return }
    }
    
    func testNRF52832Bootloader() {
        
        let fileURL = URL(asset: "nrf52832_sdk_14.1_bl_2", fileExtension: "zip")
        
        do {
            
            let zip = try DFUStreamZip(url: fileURL)
            
            guard zip.firmware.data.count == 1
                else { XCTFail("Error parsing firmware"); return }
            
            let firmwareData = zip.firmware.data[0]
            
            XCTAssertEqual(firmwareData.data.count, 23724, "Expected 24KB")
            XCTAssertEqual(firmwareData.initPacket?.count, 135)
            XCTAssertEqual(firmwareData.type, [.bootloader])
        }
            
        catch { XCTFail("\(error)"); return }
    }
    
    func testNRF52832SoftdeviceBootloaderApplication() {
        
        let fileURL = URL(asset: "nrf52832_sdk_14.1_sd_bl_app_3", fileExtension: "zip")
        
        do {
            
            let zip = try DFUStreamZip(url: fileURL)
            
            guard zip.firmware.data.count == 2
                else { XCTFail("Error parsing firmware"); return }
            
            let firmwareData = zip.firmware.data[0]
            
            XCTAssertEqual(firmwareData.data.count, 160084, "Expected 160KB")
            XCTAssertEqual(firmwareData.initPacket?.count, 137)
            XCTAssertEqual(firmwareData.type, [.bootloader, .softdevice])
            
            let applicationData = zip.firmware.data[1]
            
            XCTAssertEqual(applicationData.data.count, 39948, "Expected 40KB")
            XCTAssertEqual(applicationData.initPacket?.count, 135)
            XCTAssertEqual(applicationData.type, [.application])
        }
            
        catch { XCTFail("\(error)"); return }
    }
}
