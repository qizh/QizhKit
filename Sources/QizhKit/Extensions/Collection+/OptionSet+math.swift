//
//  OptionSet+math.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 13.12.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension OptionSet {
	@inlinable
	public static func + (lhs: Self, rhs: Self) -> Self {
		lhs.union(rhs)
	}
}
