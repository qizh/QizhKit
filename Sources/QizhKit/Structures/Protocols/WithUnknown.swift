//
//  DefaultCase.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 13.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import Combine

public protocol WithUnknown: WithAnyUnknown {
	static var unknown: Self { get }
}

public protocol WithAnyUnknown {
	static var anyUnknown: Any { get }
}

public extension WithUnknown {
	static var anyUnknown: Any { Self.unknown }
}

// MARK: Compare

public extension WithUnknown where Self: Equatable {
	@inlinable var isUnknown: Bool { self == .unknown }
	@inlinable var isKnown: Bool { self != .unknown }
	@inlinable var known: Self? { isKnown ? self : nil }
}

public extension WithUnknown where Self: EasySelfComparable {
	@inlinable var isUnknownCase: Bool { self.is(.unknown) }
	@inlinable var isKnownCase: Bool { self.is(not: .unknown) }
	@inlinable var knownCase: Self? { isKnownCase ? self : nil }
}

// MARK: Collection

public extension Collection where Element: WithUnknown, Element: Equatable {
	@inlinable var known: [Element] { filter(\.isKnown) }
}

public extension Collection where Element: WithUnknown, Element: EasySelfComparable {
	@inlinable var knownCases: [Element] { filter(not: .unknown) }
}

// MARK: Case: [First, Last]

private let nonEmptyAllCasesAssumption = """
	Assuming that a `CaseIterable` structure has `allCases` variable \
	filled with at least one element.
"""

public protocol UnknownCaseFirst: WithUnknown, CaseIterable, StringIterable { }
public extension UnknownCaseFirst {
	static var unknown: Self { Self.allCases.first.forceUnwrap(because: nonEmptyAllCasesAssumption) }
}

public protocol UnknownCaseLast: WithUnknown, CaseIterable, StringIterable where AllCases: BidirectionalCollection { }
public extension UnknownCaseLast {
	static var unknown: Self { Self.allCases.last.forceUnwrap(because: nonEmptyAllCasesAssumption) }
}

// MARK: + RawRepresentable

public extension RawRepresentable
	where
		Self: CaseIterable,
		Self: WithUnknown,
		RawValue: Equatable
{
	init(rawValue: RawValue) {
		self = Self.allCases.first(where: \.rawValue, equals: rawValue)
			?? Self.unknown
	}
}

// MARK: + Codable

/// This is the main code to support coding to default
public extension KeyedDecodingContainer {
	func decode<Result>(_: Result.Type, forKey key: Key) -> Result where Result: WithUnknown, Result: Decodable {
		(try? decodeIfPresent(Result.self, forKey: key)) ?? Result.unknown
    }
	func decode<Result>(_: Result.Type, forKey key: Key) -> Result where Result: WithUnknown, Result: WithDefault, Result: Decodable {
		(try? decodeIfPresent(Result.self, forKey: key)) ?? Result.default
	}
}

public typealias CodableWithUnknown = Codable & WithUnknown
public typealias CodableWithUnknownFirstCase = Codable & UnknownCaseFirst
public typealias CodableWithUnknownLastCase = Codable & UnknownCaseLast

// MARK: + CaseIterable

public extension WithUnknown where Self: CaseIterable, AllCases.Element: Equatable {
	@inlinable static var allKnownCases: [AllCases.Element] { Self.allCases.known }
}

// MARK: + Publisher

public extension Publisher where Output: WithUnknown, Output: Equatable {
	@inlinable func known() -> Publishers.Filter<Self> {
		filter(\.isKnown)
	}
	
	@inlinable func unknown() -> Publishers.Filter<Self> {
		filter(\.isUnknown)
	}
}

public extension Publisher where Output: WithUnknown, Output: EasySelfComparable {
	@inlinable func known() -> Publishers.Filter<Self> {
		filter(\.isKnownCase)
	}
	
	@inlinable func unknown() -> Publishers.Filter<Self> {
		filter(\.isUnknownCase)
	}
}
