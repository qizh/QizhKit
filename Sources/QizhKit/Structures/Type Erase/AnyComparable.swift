//
//  AnyComparable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public struct AnyComparable {
	private let isEqualTo: (AnyComparable) -> Bool
	private let compareTo: (AnyComparable) -> Bool
	private let comparable: Any
	
	public init<T: Comparable>(_ comparable: T) {
		self.comparable = comparable
		self.isEqualTo = { other in
			guard let other = other.comparable as? T
			else { return false }
			return other == comparable
		}
		self.compareTo = { other in
			guard let other = other.comparable as? T
			else { return false }
			return comparable < other
		}
	}
}

extension AnyComparable: Comparable {
	public static func < (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
		lhs.compareTo(rhs)
	}
}

extension AnyComparable: Equatable {
	public static func == (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
		lhs.isEqualTo(rhs)
	}
}

public extension Comparable {
	@inlinable func asAnyComparable() -> AnyComparable {
		AnyComparable(self)
	}
}
