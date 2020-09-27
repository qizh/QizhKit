//
//  CanBeEmpty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: Protocol

public protocol AnyEmptyProvidable {
	static var anyEmpty: Any { get }
}

public protocol EmptyProvidable: AnyEmptyProvidable {
	static var empty: Self { get }
}

public extension EmptyProvidable {
	static var anyEmpty: Any { empty }
}

public protocol EmptyTestable {
	var isEmpty: Bool { get }
}

public extension EmptyTestable {
	@inlinable var isNotEmpty: Bool { !isEmpty }
	@inlinable var nonEmpty: Self? { isEmpty ? Self?.none : self }
}

public protocol EmptyComparable: Equatable, EmptyProvidable, EmptyTestable { }
public extension EmptyComparable {
	@inlinable var isEmpty: Bool { self == .empty }
}

// MARK: Mimic in other protocols

public extension Collection {
	@inlinable var isNotEmpty: Bool { !isEmpty }
	@inlinable var nonEmpty: Self? { isEmpty ? Self?.none : self }
}

public extension StringProtocol {
	@inlinable var isNotEmpty: Bool { !isEmpty }
	@inlinable var nonEmpty: Self? { isEmpty ? Self?.none : self }
}

//extension Set: EmptyTestable { }
//extension Array: CanBeEmpty { }
//extension ArraySlice: CanBeEmpty { }
//extension Dictionary: CanBeEmpty { }
//extension KeyValuePairs: CanBeEmpty { }

//extension Range: CanBeEmpty { }
//extension ClosedRange: CanBeEmpty { }

//extension String: CanBeEmpty { }
//extension Substring: CanBeEmpty { }

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
