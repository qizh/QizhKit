//
//  DefaultCase.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 13.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Default

/// - Tag: WithDefault
public protocol WithDefault: WithAnyDefault {
	static var `default`: Self { get }
}

public struct DefaultProvidable <Source: WithDefault>: WithDefault {
	public  let value: Source
	public init() { self.value = Source.default }
	public init(_:Source.Type) { self.init() }
	public static var `default`: Self { Self() }
}

public struct AnyDefaultProvidable: WithDefault {
	public static let `default`: AnyDefaultProvidable = .init(Self.self)
	public let value: Any
	private init <T: WithDefault> (_ value: T) { self.value = type(of: value).default }
	public  init <T: WithDefault> (_: T.Type)  { self.init(T.default) }
}

public protocol WithAnyDefault {
	static var anyDefault: Any { get }
}

public extension WithDefault {
	static var anyDefault: Any { Self.default }
	func asAnyDefaultProvidable() -> AnyDefaultProvidable {
		.init(Self.self)
	}
}

// MARK: Compiler Workaround

/// Sometimes preview can modify code in a way where you can't use
/// a variable name with "`" symbols. For this cases use
/// `WithDefaultValue` which has a `defaultValue` variable that
/// don't need to be put in "`"
public protocol WithDefaultValue: WithDefault {
	static var defaultValue: Self { get }
}

public extension WithDefaultValue {
	@inlinable static var `default`: Self { Self.defaultValue }
}

// MARK: Compare

public extension WithDefault where Self: Equatable {
	@inlinable var isDefault: Bool { self == .default }
	@inlinable var isNotDefault: Bool { !isDefault }
	@inlinable var nonDefault: Self? { isDefault ? nil : self }
}

public extension WithDefault where Self: CaseComparable {
	@inlinable var isDefaultCase: Bool { self.is(.default) }
	@inlinable var isNotDefaultCase: Bool { self.isNot(.default) }
	@inlinable var nonDefaultCase: Self? { isDefaultCase ? nil : self }
}

public extension WithDefault where Self: EasySelfComparable {
	@inlinable var isDefaultCase: Bool { self.is(.default) }
	@inlinable var isNotDefaultCase: Bool { self.is(not: .default) }
	@inlinable var nonDefaultCase: Self? { isDefaultCase ? nil : self }
}

// MARK: Collection

public extension Collection where Element: WithDefault, Element: Equatable {
	var nonDefault: [Element] {
		filter(\.isNotDefault)
	}
}

public extension Collection where Element: WithDefault, Element: EasySelfComparable {
	var nonDefaultCase: [Element] {
		filter(\.isNotDefaultCase)
	}
}

// MARK: Case: [First, Last]

private let nonEmptyAllCasesAssumption = """
	Assuming that a `CaseIterable` structure has `allCases` variable \
	filled with at least one element.
"""

public protocol DefaultCaseFirst: WithDefault, CaseIterable, StringIterable { }
public extension DefaultCaseFirst {
	static var `default`: Self { Self.allCases.first.forceUnwrap(because: nonEmptyAllCasesAssumption) }
}

public protocol DefaultCaseLast: WithDefault, CaseIterable, StringIterable where AllCases: BidirectionalCollection { }
public extension DefaultCaseLast {
	static var `default`: Self { Self.allCases.last.forceUnwrap(because: nonEmptyAllCasesAssumption) }
}

// MARK: Value: [First, Last]

public protocol DefaultsToFirstFoundValue: WithDefault { }
public extension DefaultsToFirstFoundValue {
	static var `default`: Self {
		Mirror(reflecting: self).children.first(where: \.value, is: Self.self) as! Self
	}
}

public protocol DefaultsToLastFoundValue: WithDefault { }
public extension DefaultsToLastFoundValue {
	static var `default`: Self {
		Mirror(reflecting: self).children.reversed().first(where: \.value, is: Self.self) as! Self
	}
}

// MARK: + RawRepresentable

public extension RawRepresentable
	where
		Self: CaseIterable,
		Self: WithDefault,
		RawValue: Equatable
{
	init(rawValue: RawValue) {
		self = Self.allCases.first(where: \.rawValue, equals: rawValue)
			?? Self.default
	}
}

// MARK: + Codable

/// This is the main code to support coding to default
public extension KeyedDecodingContainer {
	func decode<Result>(_: Result.Type, forKey key: Key) -> Result where Result: WithDefault, Result: Decodable {
		(try? decodeIfPresent(Result.self, forKey: key)) ?? Result.default
    }
}

public typealias CodableWithDefault = Codable & WithDefault
/// - Tag: CodableWithDefaultFirstCase
public typealias CodableWithDefaultFirstCase = Codable & DefaultCaseFirst
public typealias CodableWithDefaultLastCase = Codable & DefaultCaseLast
public typealias CodableWithDefaultFirstFoundValue = Codable & DefaultsToFirstFoundValue
public typealias CodableWithDefaultLastFoundValue = Codable & DefaultsToLastFoundValue

// MARK: + CaseIterable

public extension WithDefault where Self: CaseIterable, AllCases.Element: Equatable {
	@inlinable static var allCasesButDefault: [AllCases.Element] {
		Self.allCases.filter(\.isNotDefault)
	}
}
