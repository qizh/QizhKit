//
//  AnyNumber.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public struct AnyNumber: Numeric {
	private let add: (AnyNumber) -> AnyNumber
	private let substract: (AnyNumber) -> AnyNumber
	private let multiply: (AnyNumber) -> AnyNumber
	private let isEqualTo: (AnyNumber) -> Bool
	
	private let value: Any

	@inlinable public init?<T: BinaryInteger>(exactly source: T) {
		self.init(source)
	}
	
	public init<T: Numeric>(_ number: T) {
		self.value = number
		self.add = { other in
			guard let other = other.value as? T
			else { return AnyNumber(number) }
			return AnyNumber(number + other)
		}
		self.substract = { other in
			guard let other = other.value as? T
			else { return AnyNumber(number) }
			return AnyNumber(number - other)
		}
		self.multiply = { other in
			guard let other = other.value as? T
			else { return AnyNumber(number) }
			return AnyNumber(number * other)
		}
		self.isEqualTo = { other in
			guard let other = other.value as? T
			else { return false }
			return other == number
		}
	}
	
	public var magnitude: Double {
		Double(String(describing: value))?.magnitude ?? -1
	}
}

extension AnyNumber: Equatable {
	public static func == (lhs: AnyNumber, rhs: AnyNumber) -> Bool {
		lhs.isEqualTo(rhs)
	}
}

extension AnyNumber: AdditiveArithmetic {
	@inlinable public static func -= (lhs: inout AnyNumber, rhs: AnyNumber) {
		lhs = lhs - rhs
	}
	
	public static func - (lhs: AnyNumber, rhs: AnyNumber) -> AnyNumber {
		lhs.substract(rhs)
	}
	
	@inlinable public static func += (lhs: inout AnyNumber, rhs: AnyNumber) {
		lhs = lhs + rhs
	}
	
	public static func + (lhs: AnyNumber, rhs: AnyNumber) -> AnyNumber {
		lhs.add(rhs)
	}
	
	public static func * (lhs: AnyNumber, rhs: AnyNumber) -> AnyNumber {
		lhs.multiply(rhs)
	}
	
	@inlinable public static func *= (lhs: inout AnyNumber, rhs: AnyNumber) {
		lhs = lhs * rhs
	}
}

extension AnyNumber: ExpressibleByIntegerLiteral {
	@inlinable public init(integerLiteral value: Int) {
		self.init(value)
	}
}

public extension Numeric {
	@inlinable func asAnyNumber() -> AnyNumber {
		AnyNumber(self)
	}
}
