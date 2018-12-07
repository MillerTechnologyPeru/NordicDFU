//
//  Async.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 12/6/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import Dispatch

func mainQueue(_ block: @escaping () -> ()) {
    
    OperationQueue.main.addOperation(block)
}

/// Perform a task on the internal queue.
func async(_ block: @escaping () -> ()) {
    
    queue.async { block() }
}

let queue = DispatchQueue(label: "App Queue")
