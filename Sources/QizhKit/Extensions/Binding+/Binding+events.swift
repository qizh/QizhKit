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
		execute callback: @escaping @Sendable (Value) -> Void,
		_ flow: ExecutionFlow = .current
	) -> Binding where Value: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				flow.proceed(with: callback, value)
				self.wrappedValue = value
			}
		)
	}
	
	@available(*, deprecated, renamed: "on(change:_:)", message: "Only unified .on synthax is going to be supported")
	@discardableResult @inlinable
	func didSet(
		execute callback: @escaping @Sendable () -> Void,
		_ flow: ExecutionFlow = .current
	) -> Binding where Value: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				flow.proceed(with: callback)
				self.wrappedValue = value
			}
		)
	}
	
	@available(*, deprecated, renamed: "on(change:_:)", message: "Only unified .on synthax is going to be supported")
	@discardableResult @inlinable
	func didChange(
		execute callback: @escaping @Sendable (_ from: Value, _ to: Value) -> Void,
		_ flow: ExecutionFlow = .current
	) -> Binding where Value: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				flow.proceed(with: callback, self.wrappedValue, value)
				self.wrappedValue = value
			}
		)
	}
	
	@available(*, deprecated, renamed: "on(nil:_:)", message: "Only unified .on synthax is going to be supported")
	@inlinable func onNil<V>(
		execute callback: @escaping @Sendable () -> Void
	) -> Binding<V?> where Value == V?,
						   V: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: {
				$0.or(execute: callback)
				self.wrappedValue = $0
			}
		)
	}
}

public extension Binding where Value == Bool {
	@available(*, deprecated, renamed: "on(false:_:)", message: "Only unified .on synthax is going to be supported")
	@inlinable func onFalse(
		execute callback: @escaping @Sendable () -> Void
	) -> Binding {
		Binding(
			get: { self.wrappedValue },
			set: {
				$0.otherwise(execute: callback)
				self.wrappedValue = $0
			}
		)
	}
	
	@available(*, deprecated, renamed: "on(true:_:)", message: "Only unified .on synthax is going to be supported")
	@inlinable func onTrue(
		execute callback: @escaping @Sendable () -> Void
	) -> Binding {
		Binding(
			get: { self.wrappedValue },
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
	@inlinable func readonly<T>(
		for key: @escaping @Sendable (Value) -> T
	) -> Binding<T> where Value: Sendable {
		Binding<T>(
			get: { key(self.wrappedValue) },
			set: { _ in }
		)
	}
	
	@inlinable func optional(
		default value: Value
	) -> Binding<Value?> where Value: Sendable {
		Binding<Value?>(
			get: { self.wrappedValue },
			set: { self.wrappedValue = $0 ?? value }
		)
	}
	
	@inlinable var getter: () -> Value {
		{ self.wrappedValue }
	}
	
	@inlinable var setter: (Value) -> Void {
		{ self.wrappedValue = $0 }
	}
	
	@inlinable func getter<T>(
		for key: KeyPath<Value, T>
	) -> () -> T {
		{ self.wrappedValue[keyPath: key] }
	}
	
	@inlinable func setter<T>(
		for key: ReferenceWritableKeyPath<Value, T>
	) -> (T) -> Void {
		{ self.wrappedValue[keyPath: key] = $0 }
	}
}

// MARK: - .on change
/// `.on(condition: action)` synthax

public extension Binding {
	@discardableResult @inlinable
	func on(
		change action: @escaping @Sendable (Value) -> Void,
		       _ flow: ExecutionFlow = .current
	) -> Binding where Value: Sendable {
		.init(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				flow.proceed(with: action, value)
			}
		)
	}
	
	@discardableResult @inlinable
	func on(
		change action: @escaping @Sendable () -> Void,
		       _ flow: ExecutionFlow = .current
	) -> Binding where Value: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				flow.proceed(with: action)
			}
		)
	}
	
	@discardableResult @inlinable
	func on(
		change action: @escaping @Sendable (_ from: Value, _ to: Value) -> Void,
		       _ flow: ExecutionFlow = .current
	) -> Binding where Value: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				let previousValue = self.wrappedValue
				self.wrappedValue = value
				flow.proceed(with: action, previousValue, value)
			}
		)
	}
}

// MARK: .on MainActor change
/// `.on(condition: action)` synthax

public extension Binding {
	@discardableResult @inlinable
	func on(
		mainActorChange action: @escaping @Sendable @MainActor (Value) -> Void
	) -> Binding where Value: Sendable {
		.init(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				Task { @MainActor in
					action(value)
				}
			}
		)
	}
	
	@discardableResult @inlinable
	func on(
		mainActorChange action: @escaping @Sendable @MainActor () -> Void
	) -> Binding where Value: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				Task { @MainActor in
					action()
				}
			}
		)
	}
	
	@discardableResult @inlinable
	func on(
		mainActorChange action: @escaping @Sendable @MainActor (_ from: Value, _ to: Value) -> Void
	) -> Binding where Value: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				let previousValue = self.wrappedValue
				self.wrappedValue = value
				Task { @MainActor in
					action(previousValue, value)
				}
			}
		)
	}
}

// MARK: .on [Un] defined
/// .some() | .none

public extension Binding {
	@discardableResult @inlinable
	func on <Wrapped> (
		defined action: @escaping @Sendable (Wrapped) -> Void,
				_ flow: ExecutionFlow = .current
	) -> Binding where Value == Wrapped?,
					   Wrapped: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if let value {
					flow.proceed(with: action, value)
				}
			}
		)
	}
	
	@discardableResult @inlinable
	func on <Wrapped> (
		defined action: @escaping @Sendable () -> Void,
				_ flow: ExecutionFlow = .current
	) -> Binding where Value == Wrapped?,
					   Wrapped: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if value.isSet { flow.proceed(with: action) }
			}
		)
	}
	
	@discardableResult @inlinable
	func on <Wrapped> (
		nil action: @escaping @Sendable () -> Void,
			_ flow: ExecutionFlow = .current
	) -> Binding where Value == Wrapped?,
					   Wrapped: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if value.isNotSet { flow.proceed(with: action) }
			}
		)
	}
}

// MARK: .on MainActor [Un] defined
/// .some() | .none

public extension Binding {
	@discardableResult @inlinable
	func on <Wrapped> (
		mainActorDefined action: @escaping @Sendable @MainActor (Wrapped) -> Void
	) -> Binding where Value == Wrapped?,
					   Wrapped: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if let value {
					Task { @MainActor in
						action(value)
					}
				}
			}
		)
	}
	
	@discardableResult @inlinable
	func on <Wrapped> (
		mainActorDefined action: @escaping @Sendable @MainActor () -> Void
	) -> Binding where Value == Wrapped?,
					   Wrapped: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if value.isSet {
					Task { @MainActor in
						action()
					}
				}
			}
		)
	}
	
	@discardableResult @inlinable
	func on <Wrapped> (
		mainActorNil action: @escaping @Sendable @MainActor () -> Void
	) -> Binding where Value == Wrapped?,
					   Wrapped: Sendable {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if value.isNotSet {
					Task { @MainActor in
						action()
					}
				}
			}
		)
	}
}

// MARK: .on collection

public extension Binding where Value: Collection, Value: Sendable {
	@discardableResult @inlinable
	func on(
		empty action: @escaping @Sendable () -> Void,
		_ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if value.isEmpty { flow.proceed(with: action) }
			}
		)
	}
	
	@discardableResult @inlinable
	func on(
		nonEmpty action: @escaping @Sendable () -> Void,
		_ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if !value.isEmpty { flow.proceed(with: action) }
			}
		)
	}
	
	@discardableResult @inlinable
	func on(
		nonEmpty action: @escaping @Sendable (Value) -> Void,
		_ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if !value.isEmpty { flow.proceed(with: action, value) }
			}
		)
	}
}

// MARK: .on true | false
/// Bool

public extension Binding where Value == Bool {
	@inlinable func on(
		false action: @escaping @Sendable () -> Void,
		      _ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if value == false { flow.proceed(with: action) }
			}
		)
	}
	
	@inlinable func on(
		true action: @escaping @Sendable () -> Void,
		     _ flow: ExecutionFlow = .current
	) -> Binding {
		Binding(
			get: { self.wrappedValue },
			set: { value in
				self.wrappedValue = value
				if value == true { flow.proceed(with: action) }
			}
		)
	}
}

