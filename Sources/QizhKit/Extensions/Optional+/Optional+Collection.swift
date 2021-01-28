//
//  Optional+Collection.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 19.11.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Optional where Wrapped: Collection {
	@inlinable func mapElements <U> (
		_ transform: (Wrapped.Element) throws -> U
	) rethrows -> [U]? {
		switch self {
		case .some(let value): return try value.map(transform)
		case .none:            return nil
		}
	}
}

public extension Optional {
	func mapAsArray() -> [Wrapped]? {
		switch self {
		case .none: return nil
		case .some(let wrapped): return [wrapped]
		}
	}
}
