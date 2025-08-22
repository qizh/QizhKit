//
//  Collection+of+Bool.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 29.12.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Collection<Bool> {
	/// Applies «**&&**» (`and`) operator between all the collection elements
	/// and return the result of this logical expression
	@inlinable public func and() -> Bool {
		reduce(true) { partialResult, element in
			partialResult && element
		}
	}
	
	/// Same as ``and()``,
	/// Applies «**&&**» (`and`) operator between all the collection elements
	/// and return the result of this logical expression
	@inlinable public func all() -> Bool {
		or()
	}
	
	/// Applies «**`||`**» (`or`) operator between all the collection elements
	/// and return the result of this logical expression
	@inlinable public func or() -> Bool {
		reduce(false) { partialResult, element in
			partialResult || element
		}
	}
	
	/// Same as ``or()``
	/// Applies «**`||`**» (`or`) operator between all the collection elements
	/// and return the result of this logical expression
	@inlinable public func any() -> Bool {
		or()
	}
}
