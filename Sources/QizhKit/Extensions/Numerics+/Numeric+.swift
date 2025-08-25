//
//  Numeric+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Numeric {
	@inlinable static var one:        Self { 1 }
	@inlinable static var two:        Self { 2 }
	@inlinable static var three:      Self { 3 }
	@inlinable static var four:       Self { 4 }
	@inlinable static var five:       Self { 5 }
	@inlinable static var six:        Self { 6 }
	@inlinable static var seven:      Self { 7 }
	@inlinable static var eight:      Self { 8 }
	@inlinable static var nine:       Self { 9 }
	@inlinable static var ten:        Self { 10 }
	@inlinable static var dozen:      Self { 12 }
	@inlinable static var twelve:     Self { 12 }
	@inlinable static var sixteen:    Self { 16 }
	@inlinable static var twenty:     Self { 20 }
	@inlinable static var twentyFour: Self { 24 }
	@inlinable static var thirty:     Self { 30 }
	@inlinable static var fourty:     Self { 40 }
	@inlinable static var fifty:      Self { 50 }
	@inlinable static var sixty:      Self { 60 }
	@inlinable static var sixty²:     Self { Self.sixty.² }
	@inlinable static var hundred:    Self { 100 }
	@inlinable static var thousand:   Self { 1000 }

	@inlinable var isOne: Bool { self == .one }
	@inlinable var isNotOne: Bool { self != .one }
}

public extension SignedNumeric {
	@inlinable static var minusOne: Self { -.one }
	
	@inlinable var isMinusOne: Bool { self == .minusOne }
	@inlinable var isNotMinusOne: Bool { self != .minusOne }
}

public extension BinaryInteger {
	@inlinable var half:      Self { self / .two }
	@inlinable var third:     Self { self / .three }
	@inlinable var quater:    Self { self / .four }
	@inlinable var tenth:     Self { self / .ten }
	@inlinable var hundredth: Self { self / .hundred }

	@inlinable var doubled:    Self { self * .two }
	@inlinable var tripled:    Self { self * .three }
	@inlinable var quadrupled: Self { self * .four }
	@inlinable var hundred:    Self { self * .hundred }
	@inlinable var thousand:   Self { self * .thousand }
	
	@inlinable var minutesInSeconds: Self { self * .sixty }
	@inlinable var hoursInSeconds:   Self { self * .sixty² }
	@inlinable var daysInSeconds:    Self { self * Self.twentyFour.hoursInSeconds }
	
	@inlinable var next: Self { self + .one }
	@inlinable var prev: Self { self - .one }
	
	@inlinable mutating func increase() { self = next }
	@inlinable mutating func decrease() { self = prev }
	
	@inlinable var double: Double { Double(self) }
	@inlinable var cg: CGFloat { CGFloat(self) }
}

public extension FloatingPoint {
	@inlinable var half:       Self { self / .two      }
	@inlinable var third:      Self { self / .three    }
	@inlinable var quater:     Self { self / .four     }
	@inlinable var tenth:      Self { self / .ten      }
	@inlinable var hundredth:  Self { self / .hundred  }
	@inlinable var thousandth: Self { self / .thousand }
	
	@inlinable var doubled:    Self { self * .two }
	@inlinable var tripled:    Self { self * .three }
	@inlinable var quadrupled: Self { self * .four }
	@inlinable var hundred:    Self { self * .hundred }
	@inlinable var thousand:   Self { self * .thousand }
	
	@inlinable var minutesInSeconds: Self { self * .sixty }
	@inlinable var hoursInSeconds:   Self { self * .sixty² }
	@inlinable var daysInSeconds:    Self { self * Self.twentyFour.hoursInSeconds }
	
	@inlinable static var ½: Self { Self.one.half }
	@inlinable static var ⅓: Self { Self.one.third }
	@inlinable static var ¼: Self { Self.one.quater }
	
	@inlinable static var half:   Self { Self.one.half }
	@inlinable static var third:  Self { Self.one.third }
	@inlinable static var quater: Self { Self.one.quater }
	
	@inlinable static var twoThirds:    Self { Self.two.third }
	@inlinable static var threeQuaters: Self { Self.three.quater }
	
	/// 1/3 (of a point)
	@inlinable static var hairline: Self { Self.one.third }
	
	#if canImport(UIKit)
	/// 1/3, 1/2, or the whole point depending on a current display scale
	@inlinable static var pixel: Self {
		// .one / Self(UIScreen.main.scale.int)
		.one / Self(UITraitCollection.current.displayScale.int)
	}
	#endif
}

// MARK: Decode as Data

/*
public extension Numeric {
	var data: Data {
		var bytes = self
		return .init(bytes: &bytes, count: MemoryLayout<Self>.size)
	}
}
*/

extension FixedWidthInteger {
	public var data: Data {
		var bytes = self
		return Data(bytes: &bytes, count: MemoryLayout<Self>.size)
	}
}

extension BinaryFloatingPoint {
	public var data: Data {
		var value = self
		return withUnsafePointer(to: &value) {
			Data(buffer: UnsafeBufferPointer(start: $0, count: 1))
		}
	}
}

public extension DataProtocol {
	func decode<T: Numeric>(_ codingPath: [CodingKey], key: CodingKey) throws -> T {
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

// MARK: - Random

extension BinaryFloatingPoint where Self.RawSignificand: FixedWidthInteger {
	public static func random(
		in range: ClosedRange<Self>,
		seed: UInt64
	) -> Self {
		var generator = SeededRandomGenerator(seed: seed)
		return Self.random(in: range, using: &generator)
	}
	
	public static func random(
		in range: Range<Self>,
		seed: UInt64
	) -> Self {
		var generator = SeededRandomGenerator(seed: seed)
		return Self.random(in: range, using: &generator)
	}
}

extension FixedWidthInteger {
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
