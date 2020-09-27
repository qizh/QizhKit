//
//  ArraySlice+asArray.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 04.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension ArraySlice {
	@inlinable func asArray() -> [Element] { Array(self) }
}

public extension Slice {
	@inlinable func asArray() -> [Base.Element] { Array(self) }
}

public extension Collection where Element == SubSequence.Element {
	@inlinable func asArray() -> [Element] { Array(self) }
}

public extension RangeReplaceableCollection where Self == Self.SubSequence {
	@inlinable func asCollection <C> () -> C where C: RangeReplaceableCollection, C.Element == Element {
		C(self)
	}
}
