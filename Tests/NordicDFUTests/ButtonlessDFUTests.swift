//
//  ButtonlessDFUTests.swift
//  NordicDFUTests
//
//  Created by Alsey Coleman Miller on 8/30/18.
//

import Foundation
import XCTest
@testable import NordicDFU

final class ButtonlessDFUTests: XCTestCase {
    
    static var allTests = [
        ("testEnterBootloaderRequest", testEnterBootloaderRequest),
        ("testEnterBootloaderResponse", testEnterBootloaderResponse)
    ]
    
    func testEnterBootloaderRequest() {
        
        // peripheral.writeValue(0x01, for: 8EC90003-F315-4F60-9FB8-838830DAEA50, type: .withResponse)
        
        let data = Data([0x01])
        
        guard let value = ButtonlessDFUValue(data: data)
            else { XCTFail(); return }
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(ButtonlessDFUValue.request(.enterBootloader).data, data)
    }
    
    func testEnterBootloaderResponse() {
        
        // Indication received from 8EC90003-F315-4F60-9FB8-838830DAEA50, value (0x):200101
        // Response (Op Code = 1, Status = 1) received
        
        let data = Data([0x20, 0x01, 0x01])
        
        let response = ButtonlessDFUResponse(request: .enterBootloader, status: .success)
        
        guard let value = ButtonlessDFUResponse(data: data)
            else { XCTFail(); return }
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(response, value)
    }
}
