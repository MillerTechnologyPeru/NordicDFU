//
//  Data.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/29/18.
//

import Foundation

#if swift(>=3.1)
#elseif swift(>=3.0)
internal extension Data {
    
    static func += (data: inout Data, bytes: [UInt8]) {
        
        data.append(contentsOf: bytes)
    }
    
    static func += (rhs: inout Data, lhs: Data) {
        
        rhs.append(lhs)
    }
}
#endif

internal extension Data {
    
    func subdataNoCopy(in range: CountableRange<Int>) -> Data {
        
        let pointer = withUnsafeBytes { UnsafeMutableRawPointer(mutating: $0).advanced(by: range.lowerBound) }
        
        return Data(bytesNoCopy: pointer, count: range.count, deallocator: .none)
    }
    
    func suffixNoCopy(from index: Int) -> Data {
        
        return subdataNoCopy(in: index ..< count)
    }
}
