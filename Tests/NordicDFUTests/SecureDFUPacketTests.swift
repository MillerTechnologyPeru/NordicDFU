//
//  SecureDFUPacketTests.swift
//  NordicDFUTests
//
//  Created by Alsey Coleman Miller on 8/30/18.
//

import Foundation
import XCTest
@testable import NordicDFU

final class SecureDFUPacketTests: XCTestCase {
    
    func testSendInitPacket() {
        
        /**
         15:31:12.103 Writing to characteristic 8EC90002-F315-4F60-9FB8-838830DAEA50...
         15:31:12.103 peripheral.writeValue(0x1284010a3e0801123a080110341a029d01200028, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
         15:31:12.103 Writing to characteristic 8EC90002-F315-4F60-9FB8-838830DAEA50...
         15:31:12.104 peripheral.writeValue(0x00300038aca107422408031220ac5446d011c159, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
         15:31:12.104 Writing to characteristic 8EC90002-F315-4F60-9FB8-838830DAEA50...
         15:31:12.104 peripheral.writeValue(0xda7de2b2c19780b90e2a7576b737ea83aed95948, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
         15:31:12.104 Writing to characteristic 8EC90002-F315-4F60-9FB8-838830DAEA50...
         15:31:12.105 peripheral.writeValue(0xe25fd64e7a480010001a4038684a7accee620401, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
         15:31:12.105 Writing to characteristic 8EC90002-F315-4F60-9FB8-838830DAEA50...
         15:31:12.105 peripheral.writeValue(0x21554139f44e57601fd85e283e56a8e12964ec4f, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
         15:31:12.105 Writing to characteristic 8EC90002-F315-4F60-9FB8-838830DAEA50...
         15:31:12.106 peripheral.writeValue(0x7c097d644086d906e74673b33f6f684594d02a18, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
         15:31:12.106 Writing to characteristic 8EC90002-F315-4F60-9FB8-838830DAEA50...
         15:31:12.106 peripheral.writeValue(0xc3b36aa157281813d8baed473e4571, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
         15:31:12.106 Command object sent (CRC = E856963B)
         */
        
        let chunks: [Data] = [
            // 15:31:12.103 peripheral.writeValue(0x1284010a3e0801123a080110341a029d01200028, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
            hexData("0x1284010a3e0801123a080110341a029d01200028"), //[0x12, 0x84, 0x01, 0x0a, 0x3e, 0x08, 0x01, 0x12, 0x3a, 0x08, 0x01, 0x10, 0x34, 0x1a, 0x02, 0x9d, 0x01, 0x20, 0x00, 0x28],
            
            // 15:31:12.104 peripheral.writeValue(0x00300038aca107422408031220ac5446d011c159, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
            hexData("0x00300038aca107422408031220ac5446d011c159"), //[0x00, 0x30, 0x00, 0x38, 0xac, 0xa1, 0x07, 0x42, 0x24, 0x08, 0x03, 0x12, 0x20, 0xa, 0xc, 0x54, 0x46, 0xd, 0x01, 0x1, 0xc1, 0x59],
            
            // 15:31:12.104 peripheral.writeValue(0xda7de2b2c19780b90e2a7576b737ea83aed95948, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
            hexData("0xda7de2b2c19780b90e2a7576b737ea83aed95948"),
            
            // 15:31:12.105 peripheral.writeValue(0xe25fd64e7a480010001a4038684a7accee620401, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
            hexData("0xe25fd64e7a480010001a4038684a7accee620401"),
            
            // 15:31:12.105 peripheral.writeValue(0x21554139f44e57601fd85e283e56a8e12964ec4f, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
            hexData("0x21554139f44e57601fd85e283e56a8e12964ec4f"),
            
            // 15:31:12.106 peripheral.writeValue(0x7c097d644086d906e74673b33f6f684594d02a18, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
            hexData("0x7c097d644086d906e74673b33f6f684594d02a18"),
            
            // 15:31:12.106 peripheral.writeValue(0xc3b36aa157281813d8baed473e4571, for: 8EC90002-F315-4F60-9FB8-838830DAEA50, type: .withoutResponse)
            hexData("0xc3b36aa157281813d8baed473e4571")
        ]
        
        let initPacket = chunks.reduce(Data(), { $0.0 + $0.1 })
        
        let expected: [UInt8] = [0x12, 0x84, 0x1, 0xa, 0x3e, 0x8, 0x1, 0x12, 0x3a, 0x8, 0x1, 0x10, 0x34, 0x1a, 0x2, 0x9d, 0x1, 0x20, 0x0, 0x28, 0x0, 0x30, 0x0, 0x38, 0xac, 0xa1, 0x7, 0x42, 0x24, 0x8, 0x3, 0x12, 0x20, 0xac, 0x54, 0x46, 0xd0, 0x11, 0xc1, 0x59, 0xda, 0x7d, 0xe2, 0xb2, 0xc1, 0x97, 0x80, 0xb9, 0xe, 0x2a, 0x75, 0x76, 0xb7, 0x37, 0xea, 0x83, 0xae, 0xd9, 0x59, 0x48, 0xe2, 0x5f, 0xd6, 0x4e, 0x7a, 0x48, 0x0, 0x10, 0x0, 0x1a, 0x40, 0x38, 0x68, 0x4a, 0x7a, 0xcc, 0xee, 0x62, 0x4, 0x1, 0x21, 0x55, 0x41, 0x39, 0xf4, 0x4e, 0x57, 0x60, 0x1f, 0xd8, 0x5e, 0x28, 0x3e, 0x56, 0xa8, 0xe1, 0x29, 0x64, 0xec, 0x4f, 0x7c, 0x9, 0x7d, 0x64, 0x40, 0x86, 0xd9, 0x6, 0xe7, 0x46, 0x73, 0xb3, 0x3f, 0x6f, 0x68, 0x45, 0x94, 0xd0, 0x2a, 0x18, 0xc3, 0xb3, 0x6a, 0xa1, 0x57, 0x28, 0x18, 0x13, 0xd8, 0xba, 0xed, 0x47, 0x3e, 0x45, 0x71]
        
        XCTAssertEqual([UInt8](initPacket), expected)
        XCTAssertEqual(initPacket.count, 135)
        
        // Command object sent (CRC = E856963B)
        XCTAssertEqual(CRC32(data: initPacket).crc, 0xE856963B)
    }
}
