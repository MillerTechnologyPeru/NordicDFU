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
        ]
    
    func testNRF52832Application() {
        
        let fileURL = URL(asset: "nrf52832_sdk_14.1_app", fileExtension: "zip")
        
        do {
            
            let firmwareZip = try DFUStreamZip(url: fileURL, type: [.application])
            
            
        }
        
        catch { XCTFail("\(error)"); return }
    }
}
