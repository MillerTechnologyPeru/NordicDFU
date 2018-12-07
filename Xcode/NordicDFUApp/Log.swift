//
//  Log.swift
//  NordicDFUApp
//
//  Created by Alsey Coleman Miller on 12/6/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

/// app logger function
func log(_ message: String) {

    #if os(Android)
    NSLog(message)
    #else
    print(message)
    #endif
}
