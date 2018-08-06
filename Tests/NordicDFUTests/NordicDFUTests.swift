import XCTest
@testable import NordicDFU

final class NordicDFUTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NordicDFU().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
