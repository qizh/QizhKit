//
//  Optional+or.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 08.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Optional {
	@inlinable func override(with produce: @autoclosure () throws -> Wrapped) rethrows -> Wrapped { try produce() }
	
	@inlinable func then(execute action: () throws -> Void) rethrows -> Void { if isSet { try action() } }
	
	@inlinable func     cleanMap<Output>(clean produce: @autoclosure () throws -> Output ) rethrows -> Output? { isSet ? try produce() : nil }
	@inlinable func flatCleanMap<Output>(clean produce: @autoclosure () throws -> Output?) rethrows -> Output? { isSet ? try produce() : nil }
}

/*
public extension Optional where Wrapped: Initializable {
	var or: DynamicOptionalAlternativeProducer<Wrapped> { .init(for: self) }
}
*/
public extension Optional {
	var or: OptionalAlternativeProducer<Wrapped> { .init(for: self) }
}
public extension Optional {
	@inlinable func or(_ value: @autoclosure () -> Wrapped) -> Wrapped { self ?? value() }
	@inlinable func or(execute: () throws -> Void) rethrows { if isNotSet { try execute() } }
	@inlinable func or<Value, Root>(
		assign value: Value,
		    to keyPath: ReferenceWritableKeyPath<Root, Value>,
		    on object: Root,
		       animation: Animation? = .none
	) {
		if isNotSet {
			if let animation = animation { withAnimation(animation) { object[keyPath: keyPath] = value } }
			else { object[keyPath: keyPath] = value }
		}
	}
}

public extension Optional where Wrapped: EmptyProvidable {
	@inlinable var orEmpty: Wrapped { or(.empty) }
}

/*
public extension Optional where Wrapped: EmptyTestable {
	@inlinable var orEmpty: Wrapped { or(.empty) }
}
*/

public extension Optional where Wrapped == Bool {
	@inlinable var orTrue: Wrapped { or(true) }
	@inlinable var orFalse: Wrapped { or(false) }
}

public extension Optional where Wrapped == Date {
	@inlinable var orNow: Wrapped { or(.now) }
}

public extension Optional where Wrapped: WithDefault {
	@inlinable var orDefault: Wrapped { or(.default) }
}

public extension Optional where Wrapped: WithUnknown {
	@inlinable var orUnknown: Wrapped { or(.unknown) }
}

public extension Optional where Wrapped: Numeric {
	@inlinable var orZero: Wrapped { or(.zero) }
	@inlinable var orOne: Wrapped { or(.one) }
}

public extension Optional where Wrapped: SignedNumeric {
	@inlinable var orMinusOne: Wrapped { or(.minusOne) }
}

public extension Optional where Wrapped: BinaryFloatingPoint {
	@inlinable var orZero: Wrapped { or(.zero) }
	@inlinable var orOne: Wrapped { or(.one) }
	@inlinable var orMinusOne: Wrapped { or(.minusOne) }
}

public extension Optional where Wrapped: Initializable {
	@inlinable var orNew: Wrapped { or(.init()) }
}
	
/// Methods are not inlinable because they use private `source`
public struct OptionalAlternativeProducer<Wrapped> {
	private let source: Wrapped?
	fileprivate init(for value: Wrapped?) { source = value }
	
	public func produce(value: Wrapped) -> Wrapped { source ?? value }
	public func produce(_ produce: () throws -> Wrapped) rethrows -> Wrapped { try source ?? produce() }
	public func execute(_ action: () throws -> Void) rethrows { if source.isNotSet { try action() } }
	public func option(value: Wrapped?) -> Wrapped? { source ?? value }
	public func option(_ produce: () throws -> Wrapped?) rethrows -> Wrapped? { try source ?? produce() }
}

public extension OptionalAlternativeProducer where Wrapped: EmptyProvidable {
	var empty: Wrapped { produce(value: .empty) }
}
public extension OptionalAlternativeProducer where Wrapped: Initializable {
	var new: Wrapped { produce(value: .init()) }
}
public extension OptionalAlternativeProducer where Wrapped: WithDefault {
	var `default`: Wrapped { produce(value: .default) }
}

/*
@dynamicMemberLookup
public struct DynamicOptionalAlternativeProducer<Wrapped: Initializable> {
	private let source: Wrapped?
	fileprivate init(for value: Wrapped?) { source = value }
	public func produce(_ produce: @autoclosure () throws -> Wrapped) rethrows -> Wrapped { try source ?? produce() }
	public var new: Wrapped { produce(.init()) }
	
	public subscript(dynamicMember keyPath: KeyPath<Wrapped, Wrapped>) -> Wrapped {
		produce(Wrapped()[keyPath: keyPath])
	}
}

public extension DynamicOptionalAlternativeProducer where Wrapped: PossibleEmpty {
	var empty: Wrapped { produce(.empty) }
}
public extension DynamicOptionalAlternativeProducer where Wrapped: WithDefault {
	var `default`: Wrapped { produce(.default) }
}
*/
