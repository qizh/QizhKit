//
//  CanBeEmpty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
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
	@inlinable public static var empty: URL {
		URL(string: "/").forceUnwrap(because: .created)
	}
}

extension Edge.Set: EmptyProvidable {
	@inlinable public static var empty: Edge.Set {
		[]
	}
}
