import XCTest

import NordicDFUTests

var tests = [XCTestCaseEntry]()
tests += NordicDFUTests.allTests()
XCTMain(tests)