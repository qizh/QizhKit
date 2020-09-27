//
//  Binding+didSet.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 06.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Binding {
	@available(*, deprecated, renamed: "on(change:_:)", message: "Only unified .on synthax is going to be supported")
	@discardableResult @inlinable
	func didSet(
		execute callback: @escaping (Value) -> Void,
		_ flow: ExecutionFlow = .current
	)
		-> Binding
	{
		Binding(
			get: getter,
			set: { value in
				flow.proceed(with: callback, value)
				self.wrappedValue = value
			}
		)
	}
	
	@available(*, deprecated, renamed: "on(change:_:)", message: "Only unified .on synthax is going to be supported")
	@discardableResult @inlinable
	func didSet(
		execute callback: @escaping () -> Void,
		_ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: getter,
			set: { value in
				flow.proceed(with: callback)
				self.wrappedValue = value
			}
		)
	}
	
	@available(*, deprecated, renamed: "on(change:_:)", message: "Only unified .on synthax is going to be supported")
	@discardableResult @inlinable
	func didChange(
		execute callback: @escaping (_ from: Value, _ to: Value) -> Void,
		_ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: getter,
			set: { value in
				flow.proceed(with: callback, self.wrappedValue, value)
				self.wrappedValue = value
			}
		)
	}
	
	@available(*, deprecated, renamed: "on(nil:_:)", message: "Only unified .on synthax is going to be supported")
	@inlinable func onNil<V>(execute callback: @escaping () -> Void) -> Binding<V?> where Value == V? {
		Binding(
			get: getter,
			set: {
				$0.or(execute: callback)
				self.wrappedValue = $0
			}
		)
	}
}

public extension Binding where Value == Bool {
	@available(*, deprecated, renamed: "on(false:_:)", message: "Only unified .on synthax is going to be supported")
	@inlinable func onFalse(execute callback: @escaping () -> Void) -> Binding {
		Binding(
			get: getter,
			set: {
				$0.otherwise(execute: callback)
				self.wrappedValue = $0
			}
		)
	}
	
	@available(*, deprecated, renamed: "on(true:_:)", message: "Only unified .on synthax is going to be supported")
	@inlinable func onTrue(execute callback: @escaping () -> Void) -> Binding {
		Binding(
			get: getter,
			set: {
				$0.then(execute: callback)
				self.wrappedValue = $0
			}
		)
	}
}

// MARK: - tools
/// getter, setter, readonly

public extension Binding {
	@inlinable func readonly<T>(for key: KeyPath<Value, T>) -> Binding<T> {
		Binding<T>(
			get: { self.wrappedValue[keyPath: key] },
			set: { _ in }
		)
	}
	
	@inlinable func optional(default value: Value) -> Binding<Value?> {
		Binding<Value?>(
			get: getter,
			set: { self.wrappedValue = $0 ?? value }
		)
	}
	
	@inlinable var getter: () -> Value {
		{ self.wrappedValue }
	}
	
	@inlinable var setter: (Value) -> Void {
		{ self.wrappedValue = $0 }
	}
	
	@inlinable func getter<T>(for key: KeyPath<Value, T>) -> () -> T {
		{ self.wrappedValue[keyPath: key] }
	}
	
	@inlinable func setter<T>(for key: ReferenceWritableKeyPath<Value, T>) -> (T) -> Void {
		{ self.wrappedValue[keyPath: key] = $0 }
	}
}

// MARK: - .on change
/// `.on(condition: action)` synthax

public extension Binding {
	@discardableResult @inlinable
	func on(
		change action: @escaping (Value) -> Void,
		       _ flow: ExecutionFlow = .current
	) -> Binding {
		.init(
			get: getter,
			set: { value in
				self.wrappedValue = value
				flow.proceed(with: action, value)
			}
		)
	}
	
	@discardableResult @inlinable
	func on(
		change action: @escaping () -> Void,
		       _ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: getter,
			set: { value in
				self.wrappedValue = value
				flow.proceed(with: action)
			}
		)
	}
	
	@discardableResult @inlinable
	func on(
		change action: @escaping (_ from: Value, _ to: Value) -> Void,
		       _ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: getter,
			set: { value in
				self.wrappedValue = value
				flow.proceed(with: action, self.wrappedValue, value)
			}
		)
	}
}

// MARK: .on [Un] defined
/// .some() | .none

public extension Binding {
	@discardableResult @inlinable
	func on <Wrapped> (
		defined action: @escaping (Wrapped) -> Void,
				_ flow: ExecutionFlow = .current
	) -> Binding where Value == Wrapped? {
		Binding(
			get: getter,
			set: { value in
				self.wrappedValue = value
				value.map(action, flow.proceed)
			}
		)
	}
	
	@discardableResult @inlinable
	func on <Wrapped> (
		defined action: @escaping () -> Void,
				_ flow: ExecutionFlow = .current
	) -> Binding where Value == Wrapped? {
		Binding(
			get: getter,
			set: { value in
				self.wrappedValue = value
				if value.isSet { flow.proceed(with: action) }
			}
		)
	}
	
	@discardableResult @inlinable
	func on <Wrapped> (
		nil action: @escaping () -> Void,
			_ flow: ExecutionFlow = .current
	) -> Binding where Value == Wrapped? {
		Binding(
			get: getter,
			set: { value in
				self.wrappedValue = value
				if value.isNotSet { flow.proceed(with: action) }
			}
		)
	}
}

// MARK: .on true | false
/// Bool

public extension Binding where Value == Bool {
	@inlinable func on(
		false action: @escaping () -> Void,
		      _ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: getter,
			set: { value in
				self.wrappedValue = value
				if value == false { flow.proceed(with: action) }
			}
		)
	}
	
	@inlinable func on(
		true action: @escaping () -> Void,
		     _ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: getter,
			set: { value in
				self.wrappedValue = value
				if value == true { flow.proceed(with: action) }
			}
		)
	}
}

