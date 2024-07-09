//
//  CanBeEmpty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

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

public extension EmptyTestable {
	@inlinable var isNotEmpty: Bool { !isEmpty }
	@inlinable var nonEmpty: Self? { isEmpty ? Self?.none : self }
}

// MARK: Default Test

public protocol EmptyComparable: Equatable, EmptyProvidable, EmptyTestable { }
public extension EmptyComparable {
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
