//
//  Range+clamp.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.10.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension ClosedRange where Bound: Comparable {
	/// Returns the given value clamped to the bounds of this closed range.
	///
	/// If the provided `value` is less than the range’s `lowerBound`,
	/// this method returns `lowerBound`.
	/// If `value` is greater than the range’s `upperBound`, it returns `upperBound`.
	/// Otherwise, it returns `value` unchanged.
	///
	/// This is useful for ensuring a value stays within a permissible interval
	/// (for example, constraining a percentage to `0...1` or an `index` to valid limits).
	///
	/// - Parameter value: The value to clamp within this range.
	/// - Returns: A value within `self`,
	/// 			equal to `value` if it already lies inside the range,
	///           	otherwise the nearest bound (`lowerBound` or `upperBound`).
	public func clamp(_ value: Bound) -> Bound {
		if value < lowerBound {
			lowerBound
		} else if value > upperBound {
			upperBound
		} else {
			value
		}
	}
}
