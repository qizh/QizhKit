//
//  AnyEquatable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public struct AnyEquatable {
	private let isEqualTo: (AnyEquatable) -> Bool
	private let equatable: Any
	
	public init<T: Equatable>(_ equatable: T) {
		self.equatable = equatable
		self.isEqualTo = { other in
			guard let other = other.equatable as? T
			else { return false }
			return other == equatable
		}
	}
}

extension AnyEquatable: Equatable {
	public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
		lhs.isEqualTo(rhs)
	}
}

public extension Equatable {
	@inlinable func asAnyEquatable() -> AnyEquatable {
		AnyEquatable(self)
	}
}
