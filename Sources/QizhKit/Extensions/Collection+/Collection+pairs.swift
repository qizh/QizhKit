//
//  Collection+pairs.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import SwiftUI

public extension Collection {
	typealias Pair = PairOf<Element>
	@inlinable var pairs: [Pair] {
		stride(from: 0, to: count, by: 2)
			.map {
				Pair(elements:
					self[indexes(from: $0, count: 2)].asArray()
				)
			}
	}
}

public struct PairOf<Element> {
	public let first: Element
	public let last: Element?
	
	@inlinable public var hasLast: Bool { last != nil }
	public init(first: Element, last: Element?) {
		self.first = first
		self.last = last
	}
	@inlinable public init(_ first: Element, _ last: Element?) {
		self.init(first: first, last: last)
	}
	@inlinable public init(elements: [Element]) {
		self.init(elements[0], elements[safe: 1])
	}
}

extension PairOf: Equatable where Element: Equatable { }
extension PairOf: Hashable where Element: Hashable { }
extension PairOf: Identifiable where Element: Identifiable {
	@inlinable public var id: Element.ID { first.id }
}
