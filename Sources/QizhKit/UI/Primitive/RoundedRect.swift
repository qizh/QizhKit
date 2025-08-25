//
//  RoundedCornersRectangle.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 20.12.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
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
#endif

public struct RoundedCornersRectangle: InsettableShape, Sendable {
	public var topLeft: CGFloat
	public var topRight: CGFloat
	public var bottomLeft: CGFloat
	public var bottomRight: CGFloat
	
	public var insetAmount: CGFloat
	
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
		
		self.insetAmount = .zero
	}
	
	#if canImport(UIKit)
	public init(
		_ radius: CGFloat,
		_ corners: UIRectCorner...
	) {
		let combinedCorners = if corners.isEmpty {
			UIRectCorner.allCorners
		} else {
			corners.reduce(UIRectCorner.none) { result, corner in
				result.union(corner)
			}
		}
		
		self.init(
			topLeft: combinedCorners.contains(.topLeft) ? radius : .zero,
			topRight: combinedCorners.contains(.topRight) ? radius : .zero,
			bottomLeft: combinedCorners.contains(.bottomLeft) ? radius : .zero,
			bottomRight: combinedCorners.contains(.bottomRight) ? radius : .zero
		)
	}
	#endif
	
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

		path.move(to: CGPoint(x: tl + insetAmount, y: insetAmount))
		
		path.addLine(to: CGPoint(x: width - tr - insetAmount, y: insetAmount))
		path.addArc(
			center: CGPoint(x: width - tr - insetAmount, y: tr + insetAmount),
			radius: tr,
			startAngle: .degrees(-90),
			endAngle: .degrees(0),
			clockwise: false
		)

		path.addLine(to: CGPoint(x: width - insetAmount, y: height - br - insetAmount))
		path.addArc(
			center: CGPoint(x: width - br - insetAmount, y: height - br - insetAmount),
			radius: br,
			startAngle: .degrees(0),
			endAngle: .degrees(90),
			clockwise: false
		)

		path.addLine(to: CGPoint(x: bl + insetAmount, y: height - insetAmount))
		path.addArc(
			center: CGPoint(x: bl + insetAmount, y: height - bl - insetAmount),
			radius: bl,
			startAngle: .degrees(90),
			endAngle: .degrees(180),
			clockwise: false
		)

		path.addLine(to: CGPoint(x: insetAmount, y: tl + insetAmount))
		path.addArc(
			center: CGPoint(x: tl + insetAmount, y: tl + insetAmount),
			radius: tl,
			startAngle: .degrees(180),
			endAngle: .degrees(270),
			clockwise: false
		)

		return path
	}
	
	nonisolated public func inset(by amount: CGFloat) -> some InsettableShape {
		var copy = self
		copy.insetAmount = amount
		return copy
	}
}
