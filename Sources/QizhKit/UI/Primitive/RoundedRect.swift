//
//  RoundedCornersRectangle.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 20.12.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

@available(*, deprecated, message: "Use the new `RoundedCornersRectangle` instead", renamed: "RoundedCornersRectangle")
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

public struct RoundedCornersRectangle: Shape {
	public var topLeft: CGFloat
	public var topRight: CGFloat
	public var bottomLeft: CGFloat
	public var bottomRight: CGFloat
	
	public var animatableData:
		AnimatablePair<
			AnimatablePair<CGFloat, CGFloat>,
			AnimatablePair<CGFloat, CGFloat>
		>
	{
		get {
			AnimatablePair(
				AnimatablePair(
					topLeft,
					topRight
				),
				AnimatablePair(
					bottomLeft,
					bottomRight
				)
			)
		}
		set {
			topLeft = newValue.first.first
			topRight = newValue.first.second
			bottomLeft = newValue.second.first
			bottomRight = newValue.second.second
		}
	}
	
	public init(
		topLeft: CGFloat = .zero,
		topRight: CGFloat = .zero,
		bottomLeft: CGFloat = .zero,
		bottomRight: CGFloat = .zero
	) {
		self.topLeft = topLeft
		self.topRight = topRight
		self.bottomLeft = bottomLeft
		self.bottomRight = bottomRight
	}
	
	public init(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners
	) {
		self.topLeft = corners.contains(.topLeft) ? radius : .zero
		self.topRight = corners.contains(.topRight) ? radius : .zero
		self.bottomLeft = corners.contains(.bottomLeft) ? radius : .zero
		self.bottomRight = corners.contains(.bottomRight) ? radius : .zero
	}
	
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		
		let width = rect.width
		let height = rect.height
		
		// Make sure we do not exceed the size of the rectangle
		let maxRadius = rect.smallerSide.half
		let tr = min(maxRadius, topRight)
		let tl = min(maxRadius, topLeft)
		let bl = min(maxRadius, bottomLeft)
		let br = min(maxRadius, bottomRight)

		path.move(to: CGPoint(x: tl, y: 0))
		
		path.addLine(to: CGPoint(x: width - tr, y: 0))
		path.addArc(
			center: CGPoint(x: width - tr, y: tr),
			radius: tr,
			startAngle: .degrees(-90),
			endAngle: .degrees(0),
			clockwise: false
		)

		path.addLine(to: CGPoint(x: width, y: height - br))
		path.addArc(
			center: CGPoint(x: width - br, y: height - br),
			radius: br,
			startAngle: .degrees(0),
			endAngle: .degrees(90),
			clockwise: false
		)

		path.addLine(to: CGPoint(x: bl, y: height))
		path.addArc(
			center: CGPoint(x: bl, y: height - bl),
			radius: bl,
			startAngle: .degrees(90),
			endAngle: .degrees(180),
			clockwise: false
		)

		path.addLine(to: CGPoint(x: 0, y: tl))
		path.addArc(
			center: CGPoint(x: tl, y: tl),
			radius: tl,
			startAngle: .degrees(180),
			endAngle: .degrees(270),
			clockwise: false
		)

		return path
	}
}
