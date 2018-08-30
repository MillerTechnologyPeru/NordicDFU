//
//  UnsafeDataConvertible.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/29/18.
//

import Foundation

/// Internal Data casting protocol
internal protocol UnsafeDataConvertible {
    static func += (lhs: inout Data, rhs: Self)
}

extension UnsafeDataConvertible {
    public static func += (lhs: inout Data, rhs: Self) {
        var value = rhs
        lhs.append(UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension UInt8: UnsafeDataConvertible { }
extension UInt16: UnsafeDataConvertible { }
extension UInt32: UnsafeDataConvertible { }
extension UInt64: UnsafeDataConvertible { }

extension String: UnsafeDataConvertible {
    
    public static func += (lhs: inout Data, rhs: String) {
        lhs.append(contentsOf: rhs.utf8)
    }
}
