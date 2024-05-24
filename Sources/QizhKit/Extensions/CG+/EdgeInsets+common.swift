//
//  EdgeInsets+common.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 25.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension EdgeInsets {
	static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
	@inlinable var isZero: Bool { self == .zero }
	@inlinable var isNotZero: Bool { self != .zero }
}

public extension Optional where Wrapped == EdgeInsets {
	var top:      CGFloat { self?.top      ?? .zero }
	var leading:  CGFloat { self?.leading  ?? .zero }
	var bottom:   CGFloat { self?.bottom   ?? .zero }
	var trailing: CGFloat { self?.trailing ?? .zero }
}

public extension UIEdgeInsets {
	func asEdgeInsets() -> EdgeInsets {
		.init(
			top: top,
			leading: left,
			bottom: bottom,
			trailing: right
		)
	}
}

public extension DefaultStringInterpolation {
	mutating func appendInterpolation(
		_ insets: EdgeInsets,
		f: Int = .zero
	) {
		appendInterpolation(
			  insets.top.toString(fractionDigits: f)
			+ ":" + insets.bottom.toString(fractionDigits: f)
			+ "-<" + insets.leading.toString(fractionDigits: f)
			+ ":" + insets.trailing.toString(fractionDigits: f) + ">"
		)
	}
}

public extension EdgeInsets {
	func rounded(dp: UInt) -> EdgeInsets {
		.init(
			     top: top     .rounded(dp: dp),
			 leading: leading .rounded(dp: dp),
			  bottom: bottom  .rounded(dp: dp),
			trailing: trailing.rounded(dp: dp)
		)
	}
}

public extension EdgeInsets {
	/// Compares the rounded values
	@inlinable
	func equals(_ other: Self, precision dp: UInt) -> Bool {
		self.rounded(dp: dp) == other.rounded(dp: dp)
	}
}

// MARK: Scaled

extension EdgeInsets {
	@inlinable func scaled(_ factor: Double) -> EdgeInsets {
		scaled(Factor.init(factor))
	}
	
	@inlinable func scaled(_ factor: Factor) -> EdgeInsets {
		scaled(AxisFactor.both(factor))
	}
	
	@inlinable func scaled(_ factor: AxisFactor) -> EdgeInsets {
		scaled(factor.horizontal, factor.vertical)
	}
	
	@inlinable func scaled(_ horizontal: Factor, _ vertical: Factor) -> EdgeInsets {
		EdgeInsets(
				 top: top     .scaled(vertical),
			 leading: leading .scaled(horizontal),
			  bottom: bottom  .scaled(vertical),
			trailing: trailing.scaled(horizontal)
		)
	}
}
