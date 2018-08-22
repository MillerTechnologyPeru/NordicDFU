//
//  Utilities.swift
//  NordicDFUTests
//
//  Created by Alsey Coleman Miller on 8/21/18.
//

import Foundation
import XCTest

func loadAsset(name: String, fileExtension: String) -> Data {
    
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
    
    print("Loading test asset at \(fileURL.path)")
    
    guard let assetData = try? Data(contentsOf: fileURL)
        else { fatalError("No test asset found") }
    
    return assetData
}
