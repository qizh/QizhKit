import XCTest
@testable import QizhKit

final class QizhKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(QizhKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
