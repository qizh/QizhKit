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
public protocol AcceptingOtherValues: RawRepresentable where Self.RawValue == String {
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

public enum ExtraCase<Known>: Codable
	where Known: RawRepresentable,
		  Known.RawValue == String
{
	case   known(_ known: Known)
	case unknown(_ value: String = .empty)
	
	@inlinable public init(_ value: Known) { self = .known(value) }
	
	public var known: Known? {
		switch self {
		case .known(let known): return known
		case .unknown: 			return nil
		}
	}
}

// MARK: Identifiable

extension ExtraCase: RawRepresentable {
	public init(rawValue: String) {
		self = Known(rawValue: rawValue)
			.map(Self.known)
		?? .unknown(rawValue)
	}
	
	public var rawValue: String {
		switch self {
		case   .known(let known): return known.rawValue
		case .unknown(let value): return value
		}
	}
}

// MARK: With Unknown

extension ExtraCase: Equatable where Known: Equatable { }
extension ExtraCase: Hashable where Known: Hashable { }

extension ExtraCase: WithUnknown {
	@inlinable public static var unknown: Self { .unknown() }
	
	@inlinable public var isUnknown: Bool {
		switch self {
		case .known: return false
		case .unknown: return true
		}
	}
}

// MARK: Identifiable

extension ExtraCase: Identifiable {
	@inlinable public var id: String { rawValue }
}

// MARK: String

extension ExtraCase: ExpressibleByStringLiteral, CustomStringConvertible {
	@inlinable public var description: String { rawValue }
	@inlinable public init(stringLiteral value: String) {
		self.init(rawValue: value)
	}
}

// MARK: Compare

extension ExtraCase: EasyComparable {
	@inlinable public func `is`(_ other: Known) -> Bool { rawValue == other.rawValue }
	static func == (lhs: Self, rhs: Known) -> Bool { lhs.is(rhs) }
}

// MARK: All Cases

extension ExtraCase: AnyCaseIterable where Known: CaseIterable { }
extension ExtraCase: StringIterable where Known: CaseIterable { }
extension ExtraCase: CaseIterable where Known: CaseIterable {
	/// All known cases and one empty unknown
	public static var allCases: [Self] {
		[.unknown] + Known.allCases.map(Self.known)
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

extension ExtraCase: WithDefault, WithAnyDefault where Known: WithDefault {
	@inlinable public init(_ value: Known? = nil) { self = .known(value ?? .default) }
	@inlinable public static var `default`: Self { .known(.default) }
	
	public init(from decoder: Decoder) throws {
		guard let rawValue = try? decoder.singleValueContainer().decode(Known.RawValue.self) else {
			self = .known(.default)
			return
		}
		self = Self(rawValue: rawValue)
	}
	
}

extension ExtraCase where Known: WithUnknown {
	@inlinable public init(_ value: Known?) { self = .known(value ?? .unknown) }
	@inlinable public static var unknown: Self { .known(.unknown) }
	
	public init(from decoder: Decoder) throws {
		guard let rawValue = try? decoder.singleValueContainer().decode(Known.RawValue.self) else {
			self = .known(.unknown)
			return
		}
		self = Self(rawValue: rawValue)
	}
	
}

public extension KeyedDecodingContainer {
	func decode<Known>(_: ExtraCase<Known>.Type, forKey key: Key) throws -> ExtraCase<Known> where Known: WithDefault {
        if let value = try? decodeIfPresent(ExtraCase<Known>.self, forKey: key) {
            return value
        } else {
			return .default
        }
    }
}
