//
//  Utilities.swift
//  NordicDFUTests
//
//  Created by Alsey Coleman Miller on 8/21/18.
//

import Foundation
import XCTest

extension URL {
    
    init(asset name: String, fileExtension: String) {
        
        #if Xcode // Xcode
        
        guard let fileURL = Bundle(for: NordicDFUTests.self).url(forResource: name, withExtension: fileExtension)
            else { fatalError("No test asset found") }
        
        #else // SPM
        
        let fileManager = FileManager.default
        
        guard let currentDirectory = URL(string: fileManager.currentDirectoryPath)
            else { fatalError("No current directory \(fileManager.currentDirectoryPath)") }
        
        let fileURL = currentDirectory
            .appendingPathComponent("Assets")
            .appendingPathComponent(name + "." + fileExtension)
        
        #endif
        
        self = fileURL
    }
}

func loadAsset(name: String, fileExtension: String) -> Data {
    
    let fileURL = URL(asset: name, fileExtension: fileExtension)
    
    print("Loading test asset at \(fileURL.path)")
    
    let fileManager = FileManager.default
    
    #if os(macOS)
        
    do { return try Data(contentsOf: fileURL) }
    
    catch { fatalError("No test asset found: \(error)") }
        
    #elseif os(Linux)
        
    guard let data = fileManager.contents(atPath: fileURL.path)
        else { fatalError("No test asset found")  }
    
    return data
    #endif
}

func hexData(_ string: String) -> Data {
    
    var string = string
    string.removeSubrange(string.startIndex ... string.index(after: string.startIndex)) // remove '0x'
    
    var data = Data(capacity: string.utf8.count / 2)
    
    while string.utf8.count >= 2 {
        
        let hexString = string[string.startIndex ... string.index(after: string.startIndex)]
        string.removeSubrange(string.startIndex ... string.index(after: string.startIndex))
        
        let byte = Int(hexString, radix: 16)!
        
        data.append(UInt8(byte))
    }
    
    return data
}
