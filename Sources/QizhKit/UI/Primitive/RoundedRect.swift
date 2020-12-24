//
//  RoundedCornersRectangle.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 20.12.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct RoundedRect: Shape {
	private var radius: CGFloat
	private let corners: UIRectCorner
	
	public var animatableData: CGFloat {
		get { radius }
		set { radius = newValue }
	}
	
	/*
	public var animatableData: AnimatablePair<CGFloat, UIRectCorner> {
		get { AnimatablePair(radius, corners) }
		set {
			radius = newValue.first
			corners = newValue.second
		}
	}
	*/
	
	public init(_ radius: CGFloat, _ corners: UIRectCorner = .allCorners) {
		self.radius = radius
		self.corners = corners
	}
	
	public func path(in rect: CGRect) -> Path {
		UIBezierPath(
			roundedRect: rect,
			byRoundingCorners: corners,
			cornerRadii: .square(radius)
		)
		.path()
	}
}

public extension UIBezierPath {
	@inlinable func path() -> Path { Path(cgPath) }
}

public extension UIRectCorner {
	@inlinable static var top: UIRectCorner    { [.topLeft, 	.topRight] }
	@inlinable static var bottom: UIRectCorner { [.bottomLeft, 	.bottomRight] }
	@inlinable static var left: UIRectCorner   { [.topLeft, 	.bottomLeft] }
	@inlinable static var right: UIRectCorner  { [.topRight, 	.bottomRight] }
	@inlinable static var none: UIRectCorner   { [] }
}
