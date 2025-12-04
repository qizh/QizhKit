//
//  BoolDisplayStyleTests.swift
//  QizhKit
//
//  Tests for BoolDisplayStyle.swift
//

#if swift(>=6.2) && canImport(Testing)

import Testing
import QizhKit

@Suite("BoolDisplayStyle Tests")
struct BoolDisplayStyleTests {
	
	// MARK: Enumeration Cases
	
	@Suite("Enumeration Cases")
	struct EnumerationCases {
		/// Verify that the enumeration defines all expected cases and their count.
		@Test("Case count and membership")
		func testCasesCountAndContains() {
			let all = BoolDisplayStyle.allCases
			#expect(all.count == 23)
			#expect(all.contains(.truth))
			#expect(all.contains(.logicalValue))
		}

		/// Verify that raw values of selected cases expose the correct true/false strings.
		@Test("Raw value string pairs")
		func testRawValuePairs() {
			let plusMinus = BoolDisplayStyle.plusMinus
			#expect(plusMinus.rawValue.true == "+")
			#expect(plusMinus.rawValue.false == "-")
			let truth = BoolDisplayStyle.truth
			#expect(truth.rawValue.true == "true")
			#expect(truth.rawValue.false == "false")
		}

		/// Verify that the default labeled value view style is set to `fillCircle`.
		@Test("Default labeled value view style")
		func testLabeledValueViewDefault() {
			#expect(BoolDisplayStyle.labeledValueViewDefault == .fillCircle)
		}
	}
	
	// MARK: OppositeStrings
	
	@Suite("OppositeStrings")
	struct OppositeStringsTests {
		/// Check that explicit initialization captures true/false strings and the separator and provides correct string lookup.
		@Test("True/False values from init")
		func testTrueFalseInitializer() {
			let os = OppositeStrings(true: "on", false: "off", separator: "/")
			#expect(os.true == "on")
			#expect(os.false == "off")
			#expect(os.description == "on/off")
			#expect(os.string(for: true) == "on")
			#expect(os.string(for: false) == "off")
		}

		/// Check that array and string literal initializers map to correct true/false pairs.
		@Test("Array and literal initializers")
		func testArrayAndLiteralInitializers() {
			let os1: OppositeStrings = ["yes", "no"]
			#expect(os1.true == "yes")
			#expect(os1.false == "no")
			let os2: OppositeStrings = "up|down"
			#expect(os2.true == "up")
			#expect(os2.false == "down")
		}
	}
	
	// MARK: Bool Extensions
	
	@Suite("Bool Extensions")
	struct BoolExtensionTests {
		/// Check that the `s(_:)` helper returns the correct representation for various display styles.
		@Test("String conversion using display style")
		func testStringConversion() {
			#expect(true.s(.truth) == "true")
			#expect(false.s(.truth) == "false")
			#expect(true.s(.emojiThumb) == "👍")
			#expect(false.s(.emojiThumb) == "👎")
		}
	}
	
	// MARK: LosslessStringConvertible Extensions
	
	@Suite("LosslessStringConvertible Extensions")
	struct StringConvertibleTests {
		/// Test that numeric values are correctly converted to strings via `asString()` and the `s` property.
		@Test("asString() and s property")
		func testStringRepresentations() {
			let number = 42
			#expect(number.asString() == "42")
			#expect(number.s == "42")
			let doubleVal: Double = 3.14
			#expect(doubleVal.asString() == "3.14")
			#expect(doubleVal.s == "3.14")
		}
	}
	
	// MARK: String Interpolation
	
	@Suite("String Interpolation")
	struct StringInterpolationTests {
		/// Verify that the custom interpolation overloads for booleans and display styles work correctly.
		@Test("Boolean interpolation with style")
		func testInterpolation() {
			let s1 = "\(true, .arrowUpDown)"
			#expect(s1 == "↑")
			let s2 = "\(false, style: .arrowUpDown)"
			#expect(s2 == "↓")
		}
	}
}

#else

#warning("BoolDisplayStyle tests require Swift 6.2 or later with Testing framework availability. Tests are unavailable on this configuration.")

#endif
