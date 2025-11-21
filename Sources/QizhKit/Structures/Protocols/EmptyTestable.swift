//
//  CanBeEmpty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import OrderedCollections

// MARK: Provide

public protocol AnyEmptyProvidable {
	static var anyEmpty: Any { get }
}

public protocol EmptyProvidable: AnyEmptyProvidable {
	static var empty: Self { get }
}

public extension EmptyProvidable {
	static var anyEmpty: Any { empty }
}

// MARK: Test

public protocol EmptyTestable {
	var isEmpty: Bool { get }
}

extension EmptyTestable {
	@inlinable public var isNotEmpty: Bool { not(isEmpty) }
	public var nonEmpty: Self? {
		if isEmpty {
			nil
		} else {
			self
		}
	}
}

extension Optional: EmptyTestable where Wrapped: EmptyTestable {
	@inlinable public var isEmpty: Bool {
		self?.isEmpty == true
	}
	
	@inlinable public var isNotEmpty: Bool {
		self?.isNotEmpty == true
	}
	
	@inlinable public var nonEmpty: Self? {
		switch self {
		case .none: 				nil
		case .some(let wrapped): 	wrapped.nonEmpty
		}
	}
}

// MARK: Default Test

public protocol EmptyComparable: EmptyProvidable, EmptyTestable { }
public extension EmptyComparable where Self: Equatable {
	@inlinable var isEmpty: Bool { self == .empty }
}

// MARK: Adopt

extension Set: EmptyTestable { }
extension Array: EmptyTestable { }
extension ArraySlice: EmptyTestable { }
extension Dictionary: EmptyTestable { }
extension KeyValuePairs: EmptyTestable { }
extension Mirror.Children: EmptyTestable { }

extension Range: EmptyTestable { }
extension ClosedRange: EmptyTestable { }

extension String: EmptyTestable { }
extension Substring: EmptyTestable { }

// MARK: Implement

/// Conform `OrderedDictionary` to `EmptyComparable`.
///
/// `OrderedDictionary` already has `.isEmpty` via its `Collection` conformance,
/// so it satisfies `EmptyTestable` automatically.
/// With a static `.empty` implementation it now conforms to `EmptyComparable`
extension OrderedDictionary: EmptyComparable {
	public static var empty: Self { [:] }
}

extension URL: EmptyProvidable {
	public static let empty: URL = URL(string: "/").forceUnwrap(because: .created)
}

extension Edge.Set: EmptyProvidable {
	public static let empty: Edge.Set = []
}

extension LocalizedStringKey: EmptyComparable {
	public static var empty: LocalizedStringKey { "" }
}

extension Text: EmptyComparable {
	public static let empty = Text(verbatim: .empty)
}

// MARK: SwiftUI

@available(iOS 14.0, *)
extension StateObject where ObjectType: EmptyProvidable {
	public static var empty: Self {
		.init(wrappedValue: .empty)
	}
}
extension State where Value: EmptyProvidable {
	public static var empty: Self {
		.init(initialValue: .empty)
	}
}

import Combine

extension Published where Value: EmptyProvidable {
	public static var empty: Self {
		.init(initialValue: .empty)
	}
}
