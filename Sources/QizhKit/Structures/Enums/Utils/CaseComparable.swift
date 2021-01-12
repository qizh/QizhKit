//
//  CaseComparable.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 17.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: V1 > General Protocol

public protocol EasyComparable {
	associatedtype Other
	func `is`(_ other: Other) -> Bool
}

public extension EasyComparable {
	typealias Others = [Other]
	
	@inlinable func `as`(  _ set: Other ...) -> Self? {  self.as(set) }
	@inlinable func `in`(  _ set: Other ...) -> Bool  {  self.in(set) }
	@inlinable func `is`(not set: Other ...) -> Bool  { !self.in(set) }
	
	func `as`(  _ set: Others) -> Self? { set.contains(where: self.is) ? self : .none }
	
	@inlinable func `in`(  _ set: Others) -> Bool {  set.contains(where: self.is) }
	@inlinable func `is`(not set: Others) -> Bool { !set.contains(where: self.is) }
}

public protocol EasySelfComparable: EasyComparable where Other == Self { }
public protocol EasyCaseComparable: Equatable, EasySelfComparable { }
public extension EasyCaseComparable {
	@inlinable func `is`(_ other: Self) -> Bool {
		self == other
	}
}

public protocol EasyCaseReflectingComparable: EasySelfComparable { }
public extension EasyCaseReflectingComparable {
	@inlinable func `is`(_ other: Self) -> Bool {
		String(reflecting: self) == String(reflecting: other)
	}
}

public extension EasyCaseReflectingComparable where Self: Identifiable {
	@inlinable var id: String { String(reflecting: self) }
}

extension Optional: EasyComparable where Wrapped: EasyComparable {
	@inlinable
	public func `is`(_ other: Wrapped.Other) -> Bool {
		switch self {
		case .none: return false
		case .some(let wrapped): return wrapped.is(other)
		}
	}
}

// MARK: V1

public protocol CaseComparable: CaseNameProvidable, EasyComparable { }
public extension CaseComparable {
	@inlinable func `is`(_ other: Self) -> Bool { caseName == other.caseName }
	@inlinable func isNot(_ other: Self) -> Bool { caseName != other.caseName }
	
	@inlinable func isOne(of cases: [Self]) -> Bool {
		cases.lazy.map(\.caseName).contains(caseName)
	}
	
	@inlinable func isOne(of cases: Self ...) -> Bool { isOne(of: cases) }
	@inlinable func isNotOne(of cases: Self ...) -> Bool { !isOne(of: cases) }
	@inlinable func isNotOne(of cases: [Self]) -> Bool { !isOne(of: cases) }
}

// MARK: V2

public extension CaseComparable {
	typealias v2 = CaseCompare
}

public protocol CaseCompare:
	Equatable,
	CaseIterable,
	CaseNameProvidable,
	ExpressibleByStringLiteral
{ }

public extension CaseCompare {
	/*
	@inlinable func `is`(_ other: Self) -> Bool { caseName == other.caseName }
	@inlinable func isNot(_ other: Self) -> Bool { caseName != other.caseName }
	
	@inlinable func isOne(of cases: [Self]) -> Bool {
		cases.lazy.map(\.caseName).contains(caseName)
	}
	
	@inlinable func isOne(of cases: Self ...) -> Bool { isOne(of: cases) }
	@inlinable func isNotOne(of cases: Self ...) -> Bool { !isOne(of: cases) }
	@inlinable func isNotOne(of cases: [Self]) -> Bool { !isOne(of: cases) }
	*/
	
	typealias Operator = CompareRequest<Self>.Operator
	typealias Value = CompareRequest<Self>.Value
	
	var `is`: Value { Value(for: self) }
	var isNot: Value { isnt }
	var isnt: Value { Value(for: self, opposite: true) }
}

public struct CompareRequest<Source: CaseNameProvidable & ExpressibleByStringLiteral> {
	@dynamicMemberLookup
	public struct Value: Updatable {
		private var source: Source
		private var others: [Source] = .empty
		private var opposite: Bool = false
		
		fileprivate init(for source: Source, opposite: Bool = false) {
			self.source = source
			self.opposite = opposite
		}
		
		public subscript(dynamicMember value: Source) -> Operator {
			Operator(for: appending(value, to: \.others))
		}
		
		public subscript(dynamicMember value: Source) -> Bool {
			appending(value, to: \.others).what
		}
		
		public var what: Bool {
			others.lazy.map(\.caseName).contains(source.caseName) ⊻ opposite
		}
	}
	
	public struct Operator {
		/// Other naming ideas:
		/// ```
		/// now, confess, declare, reveal, check, inspect, test, verify,
		/// validate, observe, confirm, examine, compute, count, yes, true
		/// ```
		public let confess: Bool
		public let or: Value
		
		fileprivate init(for comparator: Value) {
			or = comparator
			confess = comparator.what
		}
		
		@inlinable public func callAsFunction() -> Bool { confess }
		@inlinable public func callAsFunction(_ confession: @escaping (Bool) throws -> Void) rethrows { try confession(confess) }
		@inlinable public func callAsFunction<T>(map transform: @escaping (Bool) throws -> T) rethrows -> T { try transform(confess) }
	}
}

extension CompareRequest.Operator: Equatable {
	public static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.confess == rhs.confess
	}
}

/*
/// Since it doesn't matter which element to return,
/// returning `.first` since it's faster than `.randomElement()`.
fileprivate static var any: CaseCompareValue<CC> {
	CaseCompareValue<CC>(
		for: CC.allCases
			.first
			.forceUnwrap(
				because: "\(CC.self), conforming to `CaseIterable` should "
					+ "have `.allCases` array filled at least with one element"
			)
	)
}

ExpressibleByBooleanLiteral

public init(booleanLiteral value: Bool) {
	or = .any
	confession = value
}
*/
