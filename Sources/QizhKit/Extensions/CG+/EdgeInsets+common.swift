//
//  EdgeInsets+common.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 25.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension EdgeInsets {
	public static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
	@inlinable public var isZero: Bool { self == .zero }
	@inlinable public var isNotZero: Bool { self != .zero }
}

extension Optional where Wrapped == EdgeInsets {
	public var top:      CGFloat { self?.top      ?? .zero }
	public var leading:  CGFloat { self?.leading  ?? .zero }
	public var bottom:   CGFloat { self?.bottom   ?? .zero }
	public var trailing: CGFloat { self?.trailing ?? .zero }
}

#if canImport(UIKit)
extension UIEdgeInsets: @unchecked @retroactive Sendable {}
extension UIEdgeInsets {
	public func asEdgeInsets() -> EdgeInsets {
		EdgeInsets(
			top: top,
			leading: left,
			bottom: bottom,
			trailing: right
		)
	}
}
#endif

extension DefaultStringInterpolation {
	mutating public func appendInterpolation(
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

extension EdgeInsets {
	public func rounded(dp: UInt) -> EdgeInsets {
		EdgeInsets(
			     top: top     .rounded(dp: dp),
			 leading: leading .rounded(dp: dp),
			  bottom: bottom  .rounded(dp: dp),
			trailing: trailing.rounded(dp: dp)
		)
	}
}

extension EdgeInsets {
	/// Compares the rounded values
	@inlinable public func equals(_ other: Self, precision dp: UInt) -> Bool {
		self.rounded(dp: dp) == other.rounded(dp: dp)
	}
}

// MARK: Scaled

extension EdgeInsets {
	@inlinable public func scaled(_ factor: Double) -> EdgeInsets {
		scaled(Factor.init(factor))
	}
	
	@inlinable public func scaled(_ factor: Factor) -> EdgeInsets {
		scaled(AxisFactor.both(factor))
	}
	
	public func scaled(_ factor: AxisFactor) -> EdgeInsets {
		scaled(factor.horizontal, factor.vertical)
	}
	
	public func scaled(_ horizontal: Factor, _ vertical: Factor) -> EdgeInsets {
		EdgeInsets(
				 top: top     .scaled(vertical),
			 leading: leading .scaled(horizontal),
			  bottom: bottom  .scaled(vertical),
			trailing: trailing.scaled(horizontal)
		)
	}
}

// MARK: Increased

extension EdgeInsets {
	public func increased(
		horizontally horizontalAmount: CGFloat = .zero,
		vertically verticalAmount: CGFloat = .zero
	) -> EdgeInsets {
		EdgeInsets(
			top: top + verticalAmount.half,
			leading: leading + horizontalAmount.half,
			bottom: bottom + verticalAmount.half,
			trailing: trailing + horizontalAmount.half
		)
	}
}

// MARK: Decreased

extension EdgeInsets {
	@inlinable public func decreased(
		horizontally horizontalAmount: CGFloat = .zero,
		vertically verticalAmount: CGFloat = .zero
	) -> EdgeInsets {
		increased(horizontally: -horizontalAmount, vertically: -verticalAmount)
	}
}

// MARK: Init Defaults

extension EdgeInsets {
	@_disfavoredOverload
	public init(
		vertical: CGFloat = .zero,
		horizontal: CGFloat = .zero,
	) {
		self.init(
			top: vertical,
			leading: horizontal,
			bottom: vertical,
			trailing: horizontal
		)
	}
	
	@inlinable public init(
		all value: CGFloat
	) {
		self.init(
			top: value,
			leading: value,
			bottom: value,
			trailing: value
		)
	}
	
	@inlinable public static func horizontal(_ inset: CGFloat) -> EdgeInsets {
		.init(horizontal: inset)
	}
	
	@inlinable public static func vertical(_ inset: CGFloat) -> EdgeInsets {
		.init(vertical: inset)
	}
	
	@inlinable public static func all(_ inset: CGFloat) -> EdgeInsets {
		.init(all: inset)
	}
	
	@inlinable public static func top(_ inset: CGFloat) -> EdgeInsets {
		.init(top: inset, leading: .zero, bottom: .zero, trailing: .zero)
	}
	
	@inlinable public static func leading(_ inset: CGFloat) -> EdgeInsets {
		.init(top: .zero, leading: inset, bottom: .zero, trailing: .zero)
	}
	
	@inlinable public static func bottom(_ inset: CGFloat) -> EdgeInsets {
		.init(top: .zero, leading: .zero, bottom: inset, trailing: .zero)
	}
	
	@inlinable public static func trailing(_ inset: CGFloat) -> EdgeInsets {
		.init(top: .zero, leading: .zero, bottom: .zero, trailing: inset)
	}

}
