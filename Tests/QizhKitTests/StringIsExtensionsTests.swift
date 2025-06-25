//
//  StringIsExtensionsTests.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 25.06.2025.
//

import Testing
import QizhKit

@Suite("String extension properties tests")
struct TestStringProperties {
    @Test func testIsJson() async throws {
        #expect("{id: 2}".isJson) // expected to be true
        #expect("   {id: 2} ".isJson) // expected to be true
		#expect(!"Try to use {id: 2}".isJson) // expected to be false
    }
}
