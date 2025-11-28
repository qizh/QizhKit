//
//  QizhKitPost1_8_13Tests.swift
//  QizhKit
//
//  Created for post-1.8.13 cleanup, docs, and tests.
//

#if swift(>=6.2) && canImport(Testing)

import Testing
import QizhKit
import SwiftUI
import CoreGraphics

@Suite("Post-1.8.13 Tests")
struct QizhKitPost1_8_13Tests {
	
	// MARK: - Bool.asIntSign
	
	@Suite("Bool.asIntSign Tests")
	struct BoolAsIntSignTests {
		@Test func testTrueReturnsOne() {
			#expect(true.asIntSign == 1)
		}
		
		@Test func testFalseReturnsMinusOne() {
			#expect(false.asIntSign == -1)
		}
	}
	
	// MARK: - ClosedRange.clamp(_:)
	
	@Suite("ClosedRange.clamp Tests")
	struct ClosedRangeClampTests {
		@Test func testClampWithinRange() {
			let range: ClosedRange<Int> = 0...10
			#expect(range.clamp(5) == 5)
		}
		
		@Test func testClampBelowRange() {
			let range: ClosedRange<Int> = 0...10
			#expect(range.clamp(-5) == 0)
		}
		
		@Test func testClampAboveRange() {
			let range: ClosedRange<Int> = 0...10
			#expect(range.clamp(15) == 10)
		}
		
		@Test func testClampAtLowerBound() {
			let range: ClosedRange<Int> = 0...10
			#expect(range.clamp(0) == 0)
		}
		
		@Test func testClampAtUpperBound() {
			let range: ClosedRange<Int> = 0...10
			#expect(range.clamp(10) == 10)
		}
		
		@Test func testClampWithDoubles() {
			let range: ClosedRange<Double> = 0.0...1.0
			#expect(range.clamp(0.5) == 0.5)
			#expect(range.clamp(-0.1) == 0.0)
			#expect(range.clamp(1.5) == 1.0)
		}
	}
	
	// MARK: - TimeInterval.cg
	
	@Suite("TimeInterval.cg Tests")
	struct TimeIntervalCGTests {
		@Test func testPositiveTimeInterval() {
			let interval: TimeInterval = 5.5
			#expect(interval.cg == CGFloat(5.5))
		}
		
		@Test func testZeroTimeInterval() {
			let interval: TimeInterval = 0.0
			#expect(interval.cg == CGFloat(0.0))
		}
		
		@Test func testNegativeTimeInterval() {
			let interval: TimeInterval = -3.7
			#expect(interval.cg == CGFloat(-3.7))
		}
	}
	
	// MARK: - CGPoint Multiplication Operators
	
	@Suite("CGPoint Multiplication Tests")
	struct CGPointMultiplicationTests {
		@Test func testPointTimesScalar() {
			let point = CGPoint(x: 3.0, y: 4.0)
			let scalar: CGFloat = 2.0
			let result = point * scalar
			#expect(result.x == 6.0)
			#expect(result.y == 8.0)
		}
		
		@Test func testScalarTimesPoint() {
			let scalar: CGFloat = 2.0
			let point = CGPoint(x: 3.0, y: 4.0)
			let result = scalar * point
			#expect(result.x == 6.0)
			#expect(result.y == 8.0)
		}
		
		@Test func testPointTimesZero() {
			let point = CGPoint(x: 5.0, y: 7.0)
			let result = point * 0.0
			#expect(result.x == 0.0)
			#expect(result.y == 0.0)
		}
		
		@Test func testZeroTimesPoint() {
			let point = CGPoint(x: 5.0, y: 7.0)
			let result: CGFloat = 0.0
			let calculated = result * point
			#expect(calculated.x == 0.0)
			#expect(calculated.y == 0.0)
		}
		
		@Test func testSymmetry() {
			let point = CGPoint(x: 3.0, y: 4.0)
			let scalar: CGFloat = 2.5
			#expect((point * scalar).x == (scalar * point).x)
			#expect((point * scalar).y == (scalar * point).y)
		}
	}
	
	// MARK: - asText() Helpers
	
	@Suite("asText() Helper Tests")
	struct AsTextHelperTests {
		@Test func testStringAsText() {
			let string = "Hello"
			let text = string.asText()
			// Text doesn't have equality, so we just verify it compiles
			#expect(type(of: text) == Text.self)
		}
		
		@Test func testLocalizedStringResourceAsText() {
			let resource = LocalizedStringResource("test")
			let text = resource.asText()
			#expect(type(of: text) == Text.self)
		}
		
		@Test func testOptionalLocalizedStringResourceWithValue() {
			let resource: LocalizedStringResource? = LocalizedStringResource("test")
			let text = resource.asText()
			#expect(text != nil)
		}
		
		@Test func testOptionalLocalizedStringResourceNil() {
			let resource: LocalizedStringResource? = nil
			let text = resource.asText()
			#expect(text == nil)
		}
	}
	
	// MARK: - Animatable Typealiases
	
	@Suite("Animatable Typealias Tests")
	struct AnimatableTypealiasTests {
		@Test func testAnimatableTrio() {
			let trio: AnimatableTrio<CGFloat> = .init(
				.init(1.0, 2.0),
				3.0
			)
			#expect(trio.first.first == 1.0)
			#expect(trio.first.second == 2.0)
			#expect(trio.second == 3.0)
		}
		
		@Test func testAnimatableQuartet() {
			let quartet: AnimatableQuartet<CGFloat> = .init(
				.init(1.0, 2.0),
				.init(3.0, 4.0)
			)
			#expect(quartet.first.first == 1.0)
			#expect(quartet.first.second == 2.0)
			#expect(quartet.second.first == 3.0)
			#expect(quartet.second.second == 4.0)
		}
		
		@Test func testAnimatableCGFloatPair() {
			let pair: AnimatableCGFloatPair = .init(5.0, 10.0)
			#expect(pair.first == 5.0)
			#expect(pair.second == 10.0)
		}
		
		@Test func testAnimatableCGFloatQuartet() {
			let quartet: AnimatableCGFloatQuartet = .init(
				.init(1.0, 2.0),
				.init(3.0, 4.0)
			)
			#expect(quartet.first.first == 1.0)
			#expect(quartet.second.second == 4.0)
		}
	}
}

#else

#warning("Post-1.8.13 tests require Swift 6.2 or later with Testing framework availability. Tests for Bool.asIntSign, ClosedRange.clamp, TimeInterval.cg, CGPoint multiplication operators, asText() helpers, and animatable typealiases are unavailable.")

#endif

