//
//  SecureDFUControlPointTests.swift
//  NordicDFUTests
//
//  Created by Alsey Coleman Miller on 8/30/18.
//

import Foundation
import XCTest
@testable import NordicDFU

final class SecureDFUControlPointTests: XCTestCase {
    
    func testReadObjectInfoCommand() {
        
        // peripheral.writeValue(0x0601, for: 8EC90001-F315-4F60-9FB8-838830DAEA50, type: .withResponse)
        
        let data = Data([0x06, 0x01])
        
        guard let value = SecureDFUReadObjectInfo(data: data)
            else { XCTFail("Could not parse"); return }
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(SecureDFUReadObjectInfo(type: .command).data, data)
    }
    
    func testReadObjectInfoCommandResponse() {
        
        // Notification received from 8EC90001-F315-4F60-9FB8-838830DAEA50, value (0x): 600601000100000000000000000000
        // Command object info (Max size = 256, Offset = 0, CRC = 00000000) received
        
        let data = Data([0x60, 0x06, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        guard let value = SecureDFUResponse(data: data)
            else { XCTFail("Could not parse"); return }
        
        let response = SecureDFUReadObjectInfoResponse(maxSize: 256,
                                                       offset: 0,
                                                       crc: 0x00000000)
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(SecureDFUResponse.readObject(response).data, data)
    }
    
    func testCreateObjectCommand() {
        
        // peripheral.writeValue(0x010187000000, for: 8EC90001-F315-4F60-9FB8-838830DAEA50, type: .withResponse)
        
        let data = Data([0x01, 0x01, 0x87, 0x00, 0x00, 0x00])
        
        guard let value = SecureDFUCreateObject(data: data)
            else { XCTFail("Could not parse"); return }
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(value.type, .command)
        XCTAssertEqual(value.size, 0x87)
        
        let request = SecureDFUCreateObject(type: .command, size: 0x87)
        
        XCTAssertEqual(request.data, data)
        XCTAssertEqual(request.data, value.data)
    }
    
    func testCreateObjectCommandResponse() {
        
        // Notification received from 8EC90001-F315-4F60-9FB8-838830DAEA50, value (0x): 600101
        
        let data = Data([0x60, 0x01, 0x01])
        
        guard let value = SecureDFUResponse(data: data)
            else { XCTFail("Could not parse"); return }
        
        let response = SecureDFUSuccessResponse(request: .createObject)
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(response.data, data)
    }
    
    func testSetPRNValue() {
        
        // peripheral.writeValue(0x020000, for: 8EC90001-F315-4F60-9FB8-838830DAEA50, type: .withResponse)
        
        let data = Data([0x02, 0x00, 0x00])
        
        guard let value = SecureDFUSetPacketReceiptNotification(data: data)
            else { XCTFail("Could not parse"); return }
        
        let response: SecureDFUSetPacketReceiptNotification = 0x0000
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(response.data, data)
    }
    
    func testSetPRNValueResponse() {
        
        // Notification received from 8EC90001-F315-4F60-9FB8-838830DAEA50, value (0x): 600201
        // Packet Receipt Notif disabled (Op Code = 2, Value = 0)
        
        let data = Data([0x60, 0x02, 0x01])
        
        guard let value = SecureDFUResponse(data: data)
            else { XCTFail("Could not parse"); return }
        
        let response = SecureDFUSuccessResponse(request: .setPRNValue)
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(response.data, data)
    }
}
