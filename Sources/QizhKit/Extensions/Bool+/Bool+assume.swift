//
//  Bool+assume.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Bool {
	@inlinable var  `true`: Bool? { self ? self : nil }
	@inlinable var `false`: Bool? { self ? nil : self }
	
	@discardableResult
	@inlinable func then(execute: () -> Void) -> Bool {
		if self { execute() }
		return self
	}
	@discardableResult
	@inlinable func then<Output>(execute: () -> Output) -> Bool {
		if self { _ = execute() }
		return self
	}
	@inlinable func then<Output>(  produce: () -> Output ) -> Output? { self ? produce() : nil }
	@inlinable func then<Output>(  produce: () -> Output?) -> Output? { self ? produce() : nil }
	@inlinable func then<Output>(use value:       Output ) -> Output? { self ? value     : nil }
	@inlinable func then<Output>(use value:       Output?) -> Output? { self ? value     : nil }

	@discardableResult
	@inlinable func otherwise(execute: () -> Void) -> Bool {
		if !self { execute() }
		return self
	}
	@inlinable func otherwise<Output>(  produce: () -> Output ) -> Output? { self ? nil : produce() }
	@inlinable func otherwise<Output>(  produce: () -> Output?) -> Output? { self ? nil : produce() }
	@inlinable func otherwise<Output>(use value:       Output ) -> Output? { self ? nil : value     }
	@inlinable func otherwise<Output>(use value:       Output?) -> Output? { self ? nil : value     }
}
