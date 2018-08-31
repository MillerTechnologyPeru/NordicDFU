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
        XCTAssertEqual(SecureDFUControlPoint(data: data)?.data, data)
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
        XCTAssertEqual(SecureDFUControlPoint(data: data)?.data, data)
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
        XCTAssertEqual(SecureDFUControlPoint(data: data)?.data, data)
    }
    
    func testCreateObjectCommandResponse() {
        
        // Notification received from 8EC90001-F315-4F60-9FB8-838830DAEA50, value (0x): 600101
        
        let data = Data([0x60, 0x01, 0x01])
        
        guard let value = SecureDFUResponse(data: data)
            else { XCTFail("Could not parse"); return }
        
        let response = SecureDFUSuccessResponse(request: .createObject)
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(response.data, data)
        XCTAssertEqual(SecureDFUControlPoint(data: data)?.data, data)
    }
    
    func testSetPRNValue() {
        
        // peripheral.writeValue(0x020000, for: 8EC90001-F315-4F60-9FB8-838830DAEA50, type: .withResponse)
        
        let data = Data([0x02, 0x00, 0x00])
        
        guard let value = SecureDFUSetPacketReceiptNotification(data: data)
            else { XCTFail("Could not parse"); return }
        
        let request: SecureDFUSetPacketReceiptNotification = 0x0000 // disable PRN
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(request.data, data)
        XCTAssertEqual(SecureDFUControlPoint(data: data)?.data, data)
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
        XCTAssertEqual(SecureDFUControlPoint(data: data)?.data, data)
    }
    
    func testCalculateChecksumInitPacket() {
        
        // 15:31:12.107 Writing to characteristic 8EC90001-F315-4F60-9FB8-838830DAEA50...
        // 15:31:12.107 peripheral.writeValue(0x03, for: 8EC90001-F315-4F60-9FB8-838830DAEA50, type: .withResponse)
        // 15:31:12.219 Data written to 8EC90001-F315-4F60-9FB8-838830DAEA50
        
        let data = Data([0x03])
        
        guard let value = SecureDFUCalculateChecksumCommand(data: data)
            else { XCTFail("Could not parse"); return }
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(SecureDFURequest.calculateChecksum.data, data)
        XCTAssertEqual(SecureDFUControlPoint(data: data)?.data, data)
    }
    
    func testCalculateChecksumInitPacketResponse() {
        
        // 15:31:12.220 Notification received from 8EC90001-F315-4F60-9FB8-838830DAEA50, value (0x): 600301870000003b9656e8
        // 15:31:12.220 Checksum (Offset = 135, CRC = E856963B) received
        
        let data = hexData("0x600301870000003b9656e8")
        
        guard let value = SecureDFUCalculateChecksumResponse(data: data)
            else { XCTFail("Could not parse"); return }
        
        let response = SecureDFUCalculateChecksumResponse(offset: 135,
                                                          crc: 0xE856963B)
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(response.data, data)
        XCTAssertEqual(value.offset, response.offset)
        XCTAssertEqual(value.crc, response.crc)
        XCTAssertEqual(SecureDFUControlPoint(data: data)?.data, data)
    }
    
    func testExecuteCommand() {
        
        // 15:31:12.220 Writing to characteristic 8EC90001-F315-4F60-9FB8-838830DAEA50...
        // 15:31:12.220 peripheral.writeValue(0x04, for: 8EC90001-F315-4F60-9FB8-838830DAEA50, type: .withResponse)
        // 15:31:12.274 Data written to 8EC90001-F315-4F60-9FB8-838830DAEA50
        
        let data = Data([0x04])
        
        guard let value = SecureDFUExecuteCommand(data: data)
            else { XCTFail("Could not parse"); return }
        
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(SecureDFURequest.execute.data, data)
        XCTAssertEqual(SecureDFUControlPoint(data: data)?.data, data)
    }
    
    func testExecuteResponse() {
        
        // 15:31:12.395 Notification received from 8EC90001-F315-4F60-9FB8-838830DAEA50, value (0x): 600401
        // 15:31:12.395 Command object executed
        
        let data = hexData("0x600401")
        
        guard let value = SecureDFUResponse(data: data)
            else { XCTFail("Could not parse"); return }
        
        XCTAssertNil(value.error)
        XCTAssertEqual(value.data, data)
        XCTAssertEqual(value.rawValue.request, .execute)
        XCTAssertEqual(value.rawValue.status, .success)
    }
}
