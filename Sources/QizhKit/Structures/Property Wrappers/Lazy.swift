//
//  Lazy.swift
//  QizhKit
//
//  Created by Guillermo Muntaner Perelló on 16/06/2019.
//  Updated by Serhii Shevchenko on 27.08.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

/*
// MARK: - Lazy

/// A property wrapper which delays instantiation until first read access.
///
/// It is a reimplementation of Swift `lazy` modifier using a property wrapper.
/// As an extra on top of `lazy` it offers reseting the wrapper to its "uninitialized" state.
///
/// Usage:
/// ```swift
/// @Lazy var result = expensiveOperation()
/// // ...
/// print(result) // expensiveOperation() is executed at this point
/// ```
///
/// As an extra on top of `lazy` it offers reseting the wrapper to its "uninitialized" state.
@propertyWrapper
public struct Lazy<Value> {
	fileprivate var storage: Value?
	fileprivate let constructor: () -> Value
	
	/// Creates a lazy property with the closure
	/// to be executed to provide an initial value
	/// once the wrapped property is first accessed.
	///
	/// - Example:
	/// This constructor is automatically used
	/// when assigning the initial value of the property,
	/// so simply use:
	/// ```swift
	/// @Lazy var text = "Hello, World!"
	/// ```
	public init(wrappedValue constructor: @autoclosure @escaping () -> Value) {
		self.constructor = constructor
	}
	
	
	/// The lazily-initialized value of the property.
	///
	/// On first access, the provided constructor is executed to create and store the value,
	/// which is then returned. Subsequent accesses return the previously stored value.
	/// Assigning a new value replaces the stored value.
	public var wrappedValue: Value {
		mutating get {
			if storage == nil {
				self.storage = constructor()
			}
			return storage!
		}
		set {
			storage = newValue
		}
	}
	
	// MARK: ┗ Utils
	
	/// Resets the wrapper to its initial state.
	/// The wrapped property will be initialized on next read access.
	public mutating func reset() {
		storage = nil
	}
}

/*
extension Lazy where Value: EmptyProvidable {
	public static var empty: Self { .init(wrappedValue: .empty) }
}

extension Lazy where Value: Initializable {
	public static var empty: Self { .init(wrappedValue: .init()) }
}

extension Lazy where Value: WithDefault {
	public static var `default`: Self { .init(wrappedValue: .default) }
}

extension Lazy where Value: WithUnknown {
	public static var unknown: Self { .init(wrappedValue: .unknown) }
}
*/

// MARK: - LazyConstant

/// A property wrapper which delays instantiation until first read access and prevents
/// changing or mutating its wrapped value.
///
/// - Usage:
/// ```swift
/// @LazyConstant var result = expensiveOperation()
/// // ...
/// print(result) // expensiveOperation() is executed at this point
/// result = newResult // Compiler error
/// ```
///
/// As an extra on top of `lazy` it offers reseting the wrapper to its "uninitialized" state.
///
/// - Note: This wrapper prevents reassigning the wrapped property value
/// 	but **NOT** the wrapper itself. Reassigning the wrapper
/// 	`_value = LazyConstant(wrappedValue: "Hola!")` is possible
/// 	and since wrappers themselves need to be declared variable
/// 	there is no way to prevent it.
@propertyWrapper
public struct LazyConstant<Value> {
	fileprivate(set) var storage: Value?
	fileprivate let constructor: () -> Value
	
	/// Creates a constant lazy property with the closure
	/// to be executed to provide an initial value
	/// once the wrapped property is first accessed.
	///
	/// - Example:
	/// This constructor is automatically used
	/// when assigning the initial value of the property,
	/// so simply use:
	/// ```swift
	/// @LazyConstant var text = "Hello, World!"
	/// ```
	public init(wrappedValue constructor: @autoclosure @escaping () -> Value) {
		self.constructor = constructor
	}
	
	/// The lazily-initialized value of the property.
	///
	/// On first access, the provided constructor is executed to create and store the value,
	/// which is then returned. Subsequent accesses return the previously stored value.
	/// Assigning a new value replaces the stored value.
	public var wrappedValue: Value {
		mutating get {
			if storage == nil {
				storage = constructor()
			}
			return storage!
		}
	}
	
	// MARK: ┗ Utils
	
	/// Resets the wrapper to its initial state.
	/// The wrapped property will be initialized on next read access.
	public mutating func reset() {
		storage = nil
	}
}
*/
