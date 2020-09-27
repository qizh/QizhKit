//
//  OptionalConvertible.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 03.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public protocol OptionalConvertible: AnyRecreatable {
	var isSet: Bool { get }
	var isNotSet: Bool { get }
	var wrappedType: Any.Type { get }
	func anyForceUnwrap(because assumption: String) -> Any
}

public protocol TypedOptionalConvertible: OptionalConvertible {
	associatedtype Wrapped
	func asOptional() -> Optional<Wrapped>// { get }
	static var none: Self { get }
}

extension Optional: TypedOptionalConvertible {
	public var wrappedType: Any.Type { Wrapped.self }
	public func anyForceUnwrap(because assumption: String) -> Any {
		forceUnwrap(because: OptionalForcedUnwrapAssumption(assumption))
	}
	public func asOptional() -> Optional<Wrapped> { self }
}


public protocol AnyRecreatable {
	func recreateAny(debug: Bool, tabs: UInt) -> Any?
}

public protocol Recreatable: AnyRecreatable {
	associatedtype Wrapped
	func recreate() -> Wrapped?
}

extension Optional: AnyRecreatable {
	public func recreateAny(debug: Bool = false, tabs: UInt = .zero) -> Any? {
		let prefix: String = .tab * tabs
		switch self {
		case .some(let wrapped):
			if debug { print(prefix + "no need to recteate \(Wrapped.self)") }
			return wrapped
		case .none: ()
		}
		let any = self as Any
		if let array = any as? AnyElementCollection,
		   let optionalFirst = array.anyFirst as? OptionalConvertible,
		   optionalFirst.isSet {
			if debug { print(prefix + "recteated first \(Wrapped.self)") }
			return optionalFirst.anyForceUnwrap(because: "tested")
		} else if let initializable = any as? Initializable {
			if debug { print(prefix + "recteated initializable \(Wrapped.self)") }
			return type(of: initializable).init()
		} else if let empty = any as? AnyEmptyProvidable {
			if debug { print(prefix + "recteated empty \(Wrapped.self)") }
			return type(of: empty).anyEmpty
		} else if let iterable = any as? AnyCaseIterable,
				  let first = type(of: iterable).allAnyCases.first {
			if debug { print(prefix + "recteated first iterable \(Wrapped.self)") }
			return Any?(first) as Any
		} else if let def = any as? WithAnyDefault {
			if debug { print(prefix + "recteated default \(Wrapped.self)") }
			return .some(type(of: def).anyDefault)
		} else if let unknown = any as? WithAnyUnknown {
			if debug { print(prefix + "recteated unknown \(Wrapped.self)") }
			return .some(type(of: unknown).anyUnknown)
		} else {
			if debug { print(prefix + "can't recteate \(Wrapped.self)") }
			return self
		}
	}
}

extension Optional: Recreatable {
	@inlinable public func recreate() -> Wrapped? { self }
}
extension Optional: AnyEmptyProvidable where Wrapped: EmptyProvidable {
	@inlinable public static var anyEmpty: Any { Wrapped.empty }
	@inlinable public static var empty: Wrapped { Wrapped.empty }
	@inlinable public func recreate() -> Wrapped { .empty }
}
extension Optional where Wrapped: CaseIterable, Wrapped: RawRepresentable {
	public static var allStringRepresentations: [String] {
		Wrapped.allCases.map(\.stringValue)
	}
}
extension Optional: StringIterable, AnyCaseIterable where Wrapped: CaseIterable {
	public static var allStringRepresentations: [String] {
		Wrapped.allCases.map { "<" + caseName(of: $0, .identifiable) + ">" }
	}
	public static var allAnyCases: [Any] { Wrapped.allCases.asArray() }
	@inlinable public func recreate() -> Wrapped? { Wrapped.allCases.first }
}
extension Optional: WithAnyDefault where Wrapped: WithDefault {
	@inlinable public static var anyDefault: Any { Wrapped.default }
	@inlinable public static var `default`: Wrapped { Wrapped.default }
	@inlinable public func recreate() -> Wrapped { .default }
}
extension Optional: WithAnyUnknown where Wrapped: WithUnknown {
	@inlinable public static var anyUnknown: Any { Wrapped.unknown }
	@inlinable public static var unknown: Wrapped { Wrapped.unknown }
	@inlinable public func recreate() -> Wrapped { .unknown }
}
extension Optional: Initializable where Wrapped: Initializable {
	@inlinable public init() { self = .some(Wrapped()) }
	@inlinable public func recreate() -> Wrapped { .init() }
}

extension Optional: StringRepresentable where Wrapped: RawRepresentable {
	public var representableType: Any.Type { Wrapped.RawValue.self }
	public var stringValue: String {
		self.map(\.rawValue).map(String.init(describing:)) ?? .empty
	}
}
