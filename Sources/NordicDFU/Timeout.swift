//
//  Timeout.swift
//  NordicDFU
//
//  Created by Alsey Coleman Miller on 8/6/18.
//

import Foundation
import GATT

internal struct Timeout {
    
    let start: Date
    
    let timeout: TimeInterval
    
    var end: Date {
        
        return start + timeout
    }
    
    init(start: Date = Date(),
         timeout: TimeInterval) {
        
        self.start = start
        self.timeout = timeout
    }
    
    @discardableResult
    func timeRemaining(for date: Date = Date()) throws -> TimeInterval {
        
        let remaining = end.timeIntervalSince(date)
        
        if remaining > 0 {
            
            return remaining
            
        } else {
            
            throw CentralError.timeout
        }
    }
}
