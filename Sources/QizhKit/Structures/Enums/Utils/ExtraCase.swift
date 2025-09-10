//
//  Enum+WithAlternative.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 19.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Protocols

/// Original naming, use `AcceptingOtherValues` instead
@available(*, deprecated, renamed: "AcceptingOtherValues")
public protocol AllowUnknownCases: RawRepresentable where Self.RawValue == String {
	typealias WithUnknownCases = ExtraCase<Self>
}

/// Updated namind, better reflect meaning of this protocol
public protocol AcceptingOtherValues: RawRepresentable
	where Self.RawValue: Codable,
		  Self.RawValue: Equatable
{
	typealias AnyValue = ExtraCase<Self>
	typealias WithUnknownCases = ExtraCase<Self>
}

// MARK: String Presentation

public protocol StringRepresentable {
	var stringValue: String { get }
	var representableType: Any.Type { get }
}

public extension RawRepresentable where RawValue == String {
	var stringValue: String { rawValue }
}
public extension RawRepresentable {
	var stringValue: String { String(describing: rawValue) }
	var representableType: Any.Type { RawValue.self }
}

public protocol AnyCaseIterable {
	static var allAnyCases: [Any] { get }
}

public protocol StringIterable: AnyCaseIterable {
	static var allStringRepresentations: [String] { get }
}

public extension CaseIterable where Self: RawRepresentable {
	static var allStringRepresentations: [String] { allCases.map(\.stringValue) }
}
public extension CaseIterable where Self: StringIterable, Self: RawRepresentable {
	static var allStringRepresentations: [String] { allCases.map(\.stringValue) }
}
public extension CaseIterable where Self: AnyCaseIterable {
	static var allAnyCases: [Any] { allCases.asArray() }
}
public extension CaseIterable where Self: StringIterable {
	static var allStringRepresentations: [String] {
		allCases.map { value in
			"<" + caseName(of: value, .identifiable) + ">"
		}
	}
}

// MARK: Main

@dynamicMemberLookup
public enum ExtraCase<Known>: Codable
	where Known: RawRepresentable,
		  Known.RawValue: Equatable,
		  Known.RawValue: Codable
{
	case   known(_ known: Known)
	case unknown(_ value: Known.RawValue)
	
	@inlinable public init(_ value: Known) { self = .known(value) }
	
	public var known: Known? {
		switch self {
		case .known(let known): return known
		case .unknown: 			return nil
		}
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let rawValue = try container.decode(Known.RawValue.self)
		self.init(rawValue: rawValue)
	}
	
	public func encode(to encoder: Encoder) throws {
		try rawValue.encode(to: encoder)
	}
}

// MARK: Sendable

extension ExtraCase: Sendable where Known: Sendable, Known.RawValue: Sendable { }

// MARK: Raw Representable

extension ExtraCase: RawRepresentable where Known.RawValue: Equatable {
	public init(rawValue: Known.RawValue) {
		if let known = Known(rawValue: rawValue),
		   known.rawValue == rawValue {
			self = .known(known)
		} else {
			self = .unknown(rawValue)
		}
	}
	
	@inlinable
	public static func some(_ rawValue: Known.RawValue) -> Self {
		.init(rawValue: rawValue)
	}
	
	@inlinable
	public static func some(_ rawValue: Known.RawValue?) -> Self? {
		if let rawValue {
			.some(rawValue)
		} else {
			.none
		}
	}
	
	@inlinable
	public var rawValue: Known.RawValue {
		switch self {
		case   .known(let known): return known.rawValue
		case .unknown(let value): return value
		}
	}
}

// MARK: Equatable, Hashable

extension ExtraCase: Equatable where Known: Equatable { }
extension ExtraCase: Hashable where Known: Equatable, Known.RawValue: Hashable { }
extension ExtraCase: Comparable where Known: Equatable, Known.RawValue: Comparable {
	public static func < (lhs: ExtraCase<Known>, rhs: ExtraCase<Known>) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}

// MARK: With Unknown

extension ExtraCase: WithUnknown, WithAnyUnknown
	where Known.RawValue: Initializable
{
	@inlinable public static var unknown: Self { .unknown(.init()) }
	@inlinable public var isUnknown: Bool {
		switch self {
		case .known(_):   return false
		case .unknown(_): return true
		}
	}
	@inlinable public var isKnown: Bool {
		switch self {
		case .known(_):   return true
		case .unknown(_): return false
		}
	}
}

extension ExtraCase where Known: WithUnknown {
	@inlinable public init(_ value: Known?) { self = .known(value ?? .unknown) }
	
	public init(from decoder: Decoder) throws {
		guard let rawValue = try? decoder.singleValueContainer().decode(Known.RawValue.self) else {
			self = .unknown
			return
		}
		self.init(rawValue: rawValue)
	}
	
	@inlinable public static var unknown: Self { .known(.unknown) }
	
	/*
	@inlinable public var isUnknown: Bool {
		switch self {
		case .known(.unknown): return true
		default: return false
		}
	}
	*/
}

// MARK: With Default

extension ExtraCase: WithDefault, WithAnyDefault where Known: WithDefault {
	@inlinable public init(_ value: Known? = nil) { self = .known(value ?? .default) }
	
	public init(from decoder: Decoder) throws {
		guard let rawValue = try? decoder.singleValueContainer().decode(Known.RawValue.self) else {
			self = .default
			return
		}
		self.init(rawValue: rawValue)
	}
	
	@inlinable public static var `default`: Self { .known(.default) }
}

// MARK: Identifiable

extension ExtraCase: Identifiable where Known.RawValue: Hashable {
	@inlinable public var id: Known.RawValue { rawValue }
}

extension ExtraCase: CustomStringConvertible {
	@inlinable public var description: String { "\(rawValue)" }
}

// MARK: String

extension ExtraCase: ExpressibleByStringLiteral,
					 ExpressibleByExtendedGraphemeClusterLiteral,
					 ExpressibleByUnicodeScalarLiteral
	where Known.RawValue == String
{
	@inlinable public init(stringLiteral value: String) {
		self.init(rawValue: value)
	}
	@inlinable public init(extendedGraphemeClusterLiteral value: String) {
		self.init(rawValue: value)
	}
	@inlinable public init(unicodeScalarLiteral value: String) {
		self.init(rawValue: value)
	}
}

// MARK: Int

extension ExtraCase: ExpressibleByIntegerLiteral where IntegerLiteralType == Known.RawValue {
	@inlinable public init(integerLiteral value: Known.RawValue) {
		self.init(rawValue: value)
	}
}

// MARK: Static dynamic member: .idle → .known(.idle)

extension ExtraCase where Known: CaseNameProvider, Known: CaseIterable {
	/// Allows `.someCase` in `.known(Known.someCase)` by case name.
	public static subscript(dynamicMember member: String) -> Self {
		/// We are looking for a Known case with the same `caseName`
		if let match = Known.allCases.first(where: \.caseName, equals: member) {
			.known(match)
		} else {
			/// Without direct matching, fallback is impossible without `String` `RawValue`;
			/// let the developer see an understandable build/runtime error:
			preconditionFailure(
				"No Known case with caseName == \(member). " +
				"Provide a mapping or make Known.RawValue == String to allow unknown."
			)
		}
	}
	
	public static subscript<T>(
		dynamicMember member: T
	) -> Self where T: CaseNameProvider, T: CaseIterable {
		if let match = Known.allCases.first(where: \.caseName, equals: member.caseName) {
			.known(match)
		} else {
			preconditionFailure("\(member) is not a valid \(Known.self) case.")
		}
	}
}

// MARK: Fallback in .unknown(...) at RawValue == String

extension ExtraCase where Known: CaseNameProvider & CaseIterable, Known.RawValue == String {
	/// The same idea, but if there is no case, we use `.unknown(member)`.
	public static subscript(dynamicMember member: String) -> Self {
		if let match = Known.allCases.first(where: \.caseName, equals: member) {
			.known(match)
		} else {
			.unknown(member)
		}
	}
}

/// Option for any RawValue: only exact match by case name.
/// If the name is not found, we throw an understandable error (or change to your strategy).
public extension ExtraCase where Known: CasesBridgeProvider {
	static subscript(dynamicMember keyPath: KeyPath<Known.Type, Self>) -> Self where Known.RawValue == String {
		if let known = Known.self[keyPath: keyPath] as? Known {
			.known(known)
		} else {
			.unknown("\(Known.self[keyPath: keyPath])")
		}
	}
	
	static subscript(dynamicMember keyPath: KeyPath<Known.Type, Self>) -> Self {
		if let known = Known.self[keyPath: keyPath] as? Known {
			.known(known)
		} else {
			preconditionFailure("\(Known.self[keyPath: keyPath]) is not a valid \(Known.self) case.")
		}
	}
	
	static subscript(dynamicMember member: String) -> Self {
		if let m = Known.allCases.first(where: \.caseName, equals: member) {
			.known(m)
		} else {
			preconditionFailure(
				"No case named '\(member)' for \(Known.self). " +
				"Ensure your macro provides Cases + caseName mapping."
			)
		}
	}
}

/// Convenient fallback: if `RawValue == String`, enter unknown names in `.unknown`
public extension ExtraCase where Known: CasesBridgeProvider, Known.RawValue == String {
	static subscript(dynamicMember member: String) -> Self {
		if let k = Known.allCases.first(where: \.caseName, equals: member) {
			.known(k)
		} else if let v = Known.allCases.first(where: \.rawValue, equals: member) {
			.known(v)
		} else {
			.unknown(member)
		}
	}
}

extension ExtraCase {
	public static subscript<T>(
		dynamicMember member: T
	) -> Self where T: RawRepresentable, T.RawValue == Known.RawValue {
		self.init(rawValue: member.rawValue)
	}
	
	public static subscript(dynamicMember member: Known) -> Self {
		.known(member)
	}
	
	public static subscript<T>(dynamicMember member: T) -> Self {
		if let knownMember = member as? Known {
			self[dynamicMember: knownMember]
		} else if let rawValue = member as? Known.RawValue {
			self.init(rawValue: rawValue)
		} else {
			preconditionFailure("\(member) is not a valid \(Known.self) case.")
		}
	}
}

/*
extension ExtraCase where Known: CaseNameProvider {
	/*
	public subscript(dynamicMember: (Known) -> Self) -> Self {
		guard let knownValue = Known(rawValue: dynamicMember) else {
			
		}
	}
	*/
}

/*
extension AttributeDynamicLookup {
	public subscript<T: AttributedStringKey>(
		dynamicMember keyPath: KeyPath<AttributeScopes.MyFrameworkAttributes, T>
	) -> T {
		return self[T.self]
	}
}
*/
*/

// MARK: Compare

extension ExtraCase: EasyComparable {
	@inlinable public func `is`(_ other: Known) -> Bool { rawValue == other.rawValue }
	static func == (lhs: Self, rhs: Known) -> Bool { lhs.is(rhs) }
}

// MARK: All Cases

extension ExtraCase: AnyCaseIterable where Known: CaseIterable { }
extension ExtraCase: StringIterable where Known: CaseIterable { }
extension ExtraCase: CaseIterable where Known: CaseIterable {
	/// All known cases
	public static var allCases: [Self] {
		Known.allCases.map(Self.known)
	}
}

// MARK: T.known.item

public protocol CasesKeysProvider {
	static var instance: Self { get }
}

public protocol CasesKeysProviding {
	associatedtype CasesKeys: CasesKeysProvider
}

public extension CasesKeysProviding {
	static func value(for key: KeyPath<CasesKeys, Self>) -> Self {
		CasesKeys.instance[keyPath: key]
	}
}

public extension ExtraCase where Known: CasesKeysProviding {
	static var known: KnownCasesProvider { .init() }
	
	@dynamicMemberLookup
	struct KnownCasesProvider {
		public subscript(dynamicMember key: KeyPath<Known.CasesKeys, Known>) -> ExtraCase<Known> {
			.known(Known.value(for: key))
		}
	}
}

// MARK: Default Coding

public extension KeyedDecodingContainer {
	func decode<Known>(_: ExtraCase<Known>.Type, forKey key: Key) throws -> ExtraCase<Known> where Known: WithDefault {
		if let rawValue = try? decodeIfPresent(Known.RawValue.self, forKey: key) {
			return .init(rawValue: rawValue)
        } else {
			return .default
        }
    }
	
	func decode<Known>(_: ExtraCase<Known>.Type, forKey key: Key) throws -> ExtraCase<Known> where Known: WithUnknown {
		if let rawValue = try? decodeIfPresent(Known.RawValue.self, forKey: key) {
			return .init(rawValue: rawValue)
		} else {
			return .unknown
		}
	}
}
