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
        
        // Command object sent (CRC = E856963B)
        XCTAssertEqual(CRC32(data: initPacket).crc, 0xE856963B)
    }
}

fileprivate func hexData(_ string: String) -> Data {
    
    var string = string
    string.removeFirst(2) // remove '0x'
    
    var data = Data(capacity: string.count / 2)
    
    while string.count >= 2 {
        
        let hexString = string.prefix(2)
        string.removeFirst(2)
        
        let byte = Int(hexString, radix: 16)!
        
        data.append(UInt8(byte))
    }
    
    return data
}
