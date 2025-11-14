//
//  File.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 02.09.2025.
//

import Foundation

#if swift(>=6.2)

@available(iOS 26.0, *)
extension InlineArray {
	@inlinable public func map<T>(
		_ transform: (Element) -> T
	) -> InlineArray<count, T> {
		.init { i in transform(self[i]) }
	}
	
	@inlinable public func asCollection() -> InlineArrayCollection<count, Element> {
		.init(base: self)
	}
}

@available(iOS 26.0, *)
extension InlineArray: @retroactive Equatable where Element: Equatable {
	public static func == (
		lhs: InlineArray<count, Element>,
		rhs: InlineArray<count, Element>
	) -> Bool {
		for i in 0 ..< count {
			if lhs[i] != rhs[i] {
				return false
			}
		}
		return true
	}
}

@available(iOS 26.0, *)
extension InlineArray: @retroactive Hashable where Element: Hashable {
	public func hash(into hasher: inout Hasher) {
		for i in 0 ..< count {
			hasher.combine(self[i])
		}
	}
}

@available(iOS 26.0, *)
public struct InlineArrayCollection<let N: Int, Element>: RandomAccessCollection {
	public typealias Index = Int
	public let base: InlineArray<N, Element>

	public init(base: InlineArray<N, Element>) {
		self.base = base
	}
	
	public var startIndex: Int { 0 }
	public var endIndex: Int { N }
	public subscript(pos: Int) -> Element { base[pos] }
}

#endif
