//
//  Updatable.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 14.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public protocol Updatable {
	typealias Updater<T> = UpdatableItem<Self, T>
}

public extension Updatable {
	@inlinable func updating(with update: (inout Self) -> Void) -> Self {
		var copy = self
		update(&copy)
		return copy
	}
	
	@inlinable func updating<T>(_ keyPath: WritableKeyPath<Self, T>, with value: T) -> Self {
		var copy = self
		copy[keyPath: keyPath] = value
		return copy
	}
	
	@inlinable func updating<T>(_ keyPath: WritableKeyPath<Self, T>) -> Updater<T> {
		Updater(updating: keyPath, of: self)
	}
	
	@inlinable static func updating<T>(_ keyPath: WritableKeyPath<Self, T>, of source: Self) -> Updater<T> {
		Updater(updating: keyPath, of: source)
	}
	
	@inlinable func appending<C: RangeReplaceableCollection>(_ element: C.Element, to collectionKeyPath: WritableKeyPath<Self, C>) -> Self {
		var copy = self
		copy[keyPath: collectionKeyPath].append(element)
		return copy
	}
}

public extension Updatable where Self: Initializable {
	@inlinable static func updating<T>(_ keyPath: WritableKeyPath<Self, T>, with value: T) -> Self {
		Self().updating(keyPath, with: value)
	}
}

public struct UpdatableItem<Source, T> {
	public let source: Source
	public let keyPath: WritableKeyPath<Source, T>
	
	public init(updating keyPath: WritableKeyPath<Source, T>, of source: Source) {
		self.source = source
		self.keyPath = keyPath
	}
	
	@inlinable public func with(_ value: @autoclosure () -> T) -> Source {
		var copy = source
		copy[keyPath: keyPath] = value()
		return copy
 	}
	
	@inlinable public func with(_ updater: (T) -> T) -> Source {
		var copy = source
		copy[keyPath: keyPath] = updater(copy[keyPath: keyPath])
		return copy
	}
	
	@inlinable public func with(_ updater: (inout T) -> Void) -> Source {
		var copy = source
		var value = copy[keyPath: keyPath]
		updater(&value)
		copy[keyPath: keyPath] = value
		return copy
	}
}
