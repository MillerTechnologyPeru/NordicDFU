//
//  ManifestTests.swift
//  NordicDFUTests
//
//  Created by Alsey Coleman Miller on 8/21/18.
//

import Foundation
import XCTest
@testable import NordicDFU

final class ManifestTests: XCTestCase {
    
    static var allTests = [
        ("testManifest1", testManifest1),
        ]
    
    func testManifest1() {
        
        let jsonData = loadAsset(name: "manifest1", fileExtension: "json")
        
        let jsonDecoder = JSONDecoder()
        
        do {
            
            let manifest = try jsonDecoder.decode(DFUManifest.self, from: jsonData)
            
            XCTAssertEqual(manifest.manifest.version, 0.5)
        }
        
        catch { XCTFail("\(error)") }
    }
}
