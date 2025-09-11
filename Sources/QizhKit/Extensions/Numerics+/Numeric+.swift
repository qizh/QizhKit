//
//  Numeric+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

/// Convenience numeric constants and helpers for any `Numeric` type.
public extension Numeric {
	/// 1 as `Self`.
	@inlinable static var one:        Self { 1 }
	/// 2 as `Self`.
	@inlinable static var two:        Self { 2 }
	/// 3 as `Self`.
	@inlinable static var three:      Self { 3 }
	/// 4 as `Self`.
	@inlinable static var four:       Self { 4 }
	/// 5 as `Self`.
	@inlinable static var five:       Self { 5 }
	/// 6 as `Self`.
	@inlinable static var six:        Self { 6 }
	/// 7 as `Self`.
	@inlinable static var seven:      Self { 7 }
	/// 8 as `Self`.
	@inlinable static var eight:      Self { 8 }
	/// 9 as `Self`.
	@inlinable static var nine:       Self { 9 }
	/// 10 as `Self`.
	@inlinable static var ten:        Self { 10 }
	/// 12 as `Self` (a dozen).
	@inlinable static var dozen:      Self { 12 }
	/// 12 as `Self`.
	@inlinable static var twelve:     Self { 12 }
	/// 16 as `Self`.
	@inlinable static var sixteen:    Self { 16 }
	/// 20 as `Self`.
	@inlinable static var twenty:     Self { 20 }
	/// 24 as `Self`.
	@inlinable static var twentyFour: Self { 24 }
	/// 30 as `Self`.
	@inlinable static var thirty:     Self { 30 }
	/// 40 as `Self`.
	@inlinable static var fourty:     Self { 40 }
	/// 50 as `Self`.
	@inlinable static var fifty:      Self { 50 }
	/// 60 as `Self`.
	@inlinable static var sixty:      Self { 60 }
	/// 60 squared as `Self`.
	@inlinable static var sixty²:     Self { Self.sixty.² }
	/// 100 as `Self`.
	@inlinable static var hundred:    Self { 100 }
	/// 1000 as `Self`.
	@inlinable static var thousand:   Self { 1000 }

	/// Returns true when the value equals 1.
	@inlinable var isOne: Bool { self == .one }
	/// Returns true when the value does not equal 1.
	@inlinable var isNotOne: Bool { self != .one }
}

/// Helpers for signed numeric types.
public extension SignedNumeric {
	/// -1 as `Self`.
	@inlinable static var minusOne: Self { -.one }
	
	/// Returns true when the value equals -1.
	@inlinable var isMinusOne: Bool { self == .minusOne }
	/// Returns true when the value does not equal -1.
	@inlinable var isNotMinusOne: Bool { self != .minusOne }
}

/// Integer-specific convenience operations and unit conversions.
public extension BinaryInteger {
	/// Half of the value (integer division).
	@inlinable var half:      Self { self / .two }
	/// One third of the value (integer division).
	@inlinable var third:     Self { self / .three }
	/// One quarter of the value (integer division).
	@inlinable var quater:    Self { self / .four }
	/// One tenth of the value (integer division).
	@inlinable var tenth:     Self { self / .ten }
	/// One hundredth of the value (integer division).
	@inlinable var hundredth: Self { self / .hundred }

	/// Value multiplied by 2.
	@inlinable var doubled:    Self { self * .two }
	/// Value multiplied by 3.
	@inlinable var tripled:    Self { self * .three }
	/// Value multiplied by 4.
	@inlinable var quadrupled: Self { self * .four }
	/// Value multiplied by 10.
	@inlinable var tens:       Self { self * .ten }
	/// Value multiplied by 100.
	@inlinable var hundred:    Self { self * .hundred }
	/// Value multiplied by 1000.
	@inlinable var thousand:   Self { self * .thousand }
	
	/// Interprets the value as minutes and returns seconds.
	@inlinable var minutesInSeconds: Self { self * .sixty }
	/// Interprets the value as hours and returns seconds.
	@inlinable var hoursInSeconds:   Self { self * .sixty² }
	/// Interprets the value as days and returns seconds.
	@inlinable var daysInSeconds:    Self { self * Self.twentyFour.hoursInSeconds }
	
	/// The next integer (value + 1).
	@inlinable var next: Self { self + .one }
	/// The previous integer (value - 1).
	@inlinable var prev: Self { self - .one }
	
	/// Increments the value by 1.
	@inlinable mutating func increase() { self = next }
	/// Decrements the value by 1.
	@inlinable mutating func decrease() { self = prev }
	
	/// Converts the integer to `Double`. 
	@inlinable var double: Double { Double(self) }
	/// Converts the integer to `CGFloat`. 
	@inlinable var cg: CGFloat { CGFloat(self) }
}

/// Floating-point convenience operations, fractions, and unit conversions.
public extension FloatingPoint {
	/// Half of the value.
	@inlinable var half:       Self { self / .two      }
	/// One third of the value.
	@inlinable var third:      Self { self / .three    }
	/// One quarter of the value.
	@inlinable var quater:     Self { self / .four     }
	/// One tenth of the value.
	@inlinable var tenth:      Self { self / .ten      }
	/// One hundredth of the value.
	@inlinable var hundredth:  Self { self / .hundred  }
	/// One thousandth of the value.
	@inlinable var thousandth: Self { self / .thousand }
	
	/// Value multiplied by 2.
	@inlinable var doubled:    Self { self * .two }
	/// Value multiplied by 3.
	@inlinable var tripled:    Self { self * .three }
	/// Value multiplied by 4.
	@inlinable var quadrupled: Self { self * .four }
	/// Value multiplied by 10.
	@inlinable var tens:       Self { self * .ten }
	/// Value multiplied by 100.
	@inlinable var hundred:    Self { self * .hundred }
	/// Value multiplied by 1000.
	@inlinable var thousand:   Self { self * .thousand }
	
	/// Interprets the value as minutes and returns seconds.
	@inlinable var minutesInSeconds: Self { self * .sixty }
	/// Interprets the value as hours and returns seconds.
	@inlinable var hoursInSeconds:   Self { self * .sixty² }
	/// Interprets the value as days and returns seconds.
	@inlinable var daysInSeconds:    Self { self * Self.twentyFour.hoursInSeconds }
	
	/// 1/2 as `Self`. 
	@inlinable static var ½: Self { Self.one.half }
	/// 1/3 as `Self`. 
	@inlinable static var ⅓: Self { Self.one.third }
	/// 1/4 as `Self`. 
	@inlinable static var ¼: Self { Self.one.quater }
	
	/// 1/2 as `Self`. 
	@inlinable static var half:   Self { Self.one.half }
	/// 1/3 as `Self`. 
	@inlinable static var third:  Self { Self.one.third }
	/// 1/4 as `Self`. 
	@inlinable static var quater: Self { Self.one.quater }
	
	/// 2/3 as `Self`. 
	@inlinable static var twoThirds:    Self { Self.two.third }
	/// 3/4 as `Self`. 
	@inlinable static var threeQuaters: Self { Self.three.quater }
	
	/// 1/3 (of a point)
	@inlinable static var hairline: Self { Self.one.third }
	
	#if canImport(UIKit)
	/// Size of a device pixel in points.
	///
	/// This value is available using the ``SwiftUICore/EnvironmentValues/pixelLength``
	/// environment key. See also ``SwiftUICore/EnvironmentValues/displayScale`` related key.
	///
	/// - Note: respects current display scale received as
	/// 	```swift
	/// 	UITraitCollection.current.displayScale
	/// 	```
	///
	/// - Important: When used in SwiftUI View struct,
	/// 			  switch to ``SwiftUICore/EnvironmentValues``.
	///
	/// - SeeAlso:
	///		```swift
	///		@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
	///		extension EnvironmentValues {
	///
	///			/// The display scale of this environment.
	///			public var displayScale: CGFloat
	///
	///			/// The size of a pixel on the screen.
	///			///
	///			/// This value is usually equal to `1` divided by
	///			/// ``EnvironmentValues/displayScale``.
	///			public var pixelLength: CGFloat { get }
	///		}
	///		```
	///
	/// 	```swift
	/// 	@Environment(\.pixelLength) var pixelLength
	/// 	```
	@inlinable static var pixel: Self {
		// .one / Self(UIScreen.main.scale.int)
		.one / Self(UITraitCollection.current.displayScale.int)
	}
	#endif
}

// MARK: - Decode as Data

/// Encodes the integer value into raw `Data` using its memory representation.
extension FixedWidthInteger {
	public var data: Data {
		var bytes = self
		return Data(bytes: &bytes, count: MemoryLayout<Self>.size)
	}
}

/// Encodes the floating-point value into raw `Data` using its memory representation.
extension BinaryFloatingPoint {
	public var data: Data {
		var value = self
		return withUnsafePointer(to: &value) {
			Data(buffer: UnsafeBufferPointer(start: $0, count: 1))
		}
	}
}

/// Decodes a numeric value from raw bytes in a `DataProtocol` buffer.
public extension DataProtocol {
	/// Attempts to decode a numeric value of type `T` from this buffer.
	/// Throws if sizes mismatch.
	/// - Parameters:
	///   - codingPath: The current coding path for error reporting.
	///   - key: The key being decoded for error context.
	/// - Returns: The decoded numeric value.
	func decode<T: Numeric>(_ codingPath: [CodingKey], key: CodingKey) throws(DecodingError) -> T {
		var value: T = .zero
		guard withUnsafeMutableBytes(of: &value, copyBytes) == MemoryLayout.size(ofValue: value) else {
			throw DecodingError.dataCorrupted(
				.init(
					codingPath: codingPath,
					debugDescription: "The key \(key) could not be converted to a numeric value: \(Array(self))"
				)
			)
		}
		return value
	}
}

/// Deterministic random generation for floating-point types with a seed.
extension BinaryFloatingPoint where Self.RawSignificand: FixedWidthInteger {
	/// Returns a deterministic random value in the closed range using the given seed.
	public static func random(
		in range: ClosedRange<Self>,
		seed: UInt64
	) -> Self {
		var generator = SeededRandomGenerator(seed: seed)
		return Self.random(in: range, using: &generator)
	}
	
	/// Returns a deterministic random value in the half-open range using the given seed.
	public static func random(
		in range: Range<Self>,
		seed: UInt64
	) -> Self {
		var generator = SeededRandomGenerator(seed: seed)
		return Self.random(in: range, using: &generator)
	}
}

/// Deterministic random generation for fixed-width integers with a seed.
extension FixedWidthInteger {
	/// Returns a deterministic random value in the half-open range using the given seed.
	public static func random(
		in range: Range<Self>,
		seed: UInt64
	) -> Self {
		var generator = SeededRandomGenerator(seed: seed)
		return Self.random(in: range, using: &generator)
	}
	
	/// Returns a deterministic random value in the closed range using the given seed.
	public static func random(
		in range: ClosedRange<Self>,
		seed: UInt64
	) -> Self {
		var generator = SeededRandomGenerator(seed: seed)
		return Self.random(in: range, using: &generator)
	}
}

/*
extension <#SomeProtocol#> {
	public static func random(
		in range: Range<Self>,
		seed: UInt64
	) -> Self {
		var generator = SeededRandomGenerator(seed: seed)
		return Self.random(in: range, using: &generator)
	}
	
	public static func random(
		in range: ClosedRange<Self>,
		seed: UInt64
	) -> Self {
		var generator = SeededRandomGenerator(seed: seed)
		return Self.random(in: range, using: &generator)
	}
}
*/

