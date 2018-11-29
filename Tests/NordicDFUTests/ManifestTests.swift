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
        ("testManifest2", testManifest2)
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
    
    func testManifest2() {
        
        let jsonData = loadAsset(name: "manifest2", fileExtension: "json")
        
        let jsonDecoder = JSONDecoder()
        
        do {
            
            let manifest = try jsonDecoder.decode(DFUManifest.self, from: jsonData)
            
            XCTAssertNil(manifest.manifest.version)
            
            guard case let .application(application) = manifest.manifest
                else { XCTFail("Unexpected manifest type \(manifest)"); return }
            
            XCTAssertEqual(application.application.binFile, "app.bin")
            XCTAssertEqual(application.application.datFile, "app.dat")
            XCTAssertNil(application.version)
        }
            
        catch { XCTFail("\(error)") }
    }
}
