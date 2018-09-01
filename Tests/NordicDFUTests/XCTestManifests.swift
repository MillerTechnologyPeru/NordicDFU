import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NordicDFUTests.allTests),
        testCase(ManifestTests.allTests),
        testCase(FirmwareTests.allTests),
        testCase(ButtonlessDFUTests.allTests),
        testCase(SecureDFUPacketTests.allTests),
        testCase(SecureDFUControlPointTests.allTests),
    ]
}
#endif
