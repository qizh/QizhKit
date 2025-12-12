//
//  RoundedBorderViewModifier.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 21.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import QizhMacroKit

public extension View {
	#if canImport(UIKit)
	/// Using custom made ``RoundedCornersRectangle`` shape
	@_disfavoredOverload
	@inlinable
	func round(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners,
		border color: Color,
		weight: CGFloat = .one,
		position: LinePosition = .center,
		tap define: Bool = false
	) -> some View {
		let shape = RoundedCornersRectangle(radius, corners)
		
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.stroke(color, lineWidth: weight)
			)
			.apply(when: define) { rounded in
				rounded.contentShape(shape)
			}
	}
	
	/// Using custom made ``RoundedCornersRectangle`` shape
	@inlinable
	func round(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners,
		border style: some ShapeStyle,
		weight: CGFloat = .one,
		position: LinePosition = .center,
		tap define: Bool = false
	) -> some View {
		let shape = RoundedCornersRectangle(radius, corners)
		
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.stroke(style, lineWidth: weight)
			)
			.apply(when: define) { rounded in
				rounded.contentShape(shape)
			}
	}
	#endif
	
	/// Using custom made ``RoundedCornersRectangle`` shape
	@_disfavoredOverload
	@inlinable
	func round(
		topLeft: CGFloat,
		topRight: CGFloat,
		bottomLeft: CGFloat,
		bottomRight: CGFloat,
		border color: Color,
		weight: CGFloat = .one,
		position: LinePosition = .center,
		tap define: Bool = false
	) -> some View {
		let shape = RoundedCornersRectangle(
			topLeft: topLeft,
			topRight: topRight,
			bottomLeft: bottomLeft,
			bottomRight: bottomRight
		)
		
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.stroke(color, lineWidth: weight)
			)
			.apply(when: define) { rounded in
				rounded
					.contentShape(shape)
			}
	}
	
	/// Using custom made ``RoundedCornersRectangle`` shape
	@inlinable
	func round(
		topLeft: CGFloat,
		topRight: CGFloat,
		bottomLeft: CGFloat,
		bottomRight: CGFloat,
		border style: some ShapeStyle,
		weight: CGFloat = .one,
		position: LinePosition = .center,
		tap define: Bool = false
	) -> some View {
		let shape = RoundedCornersRectangle(
			topLeft: topLeft,
			topRight: topRight,
			bottomLeft: bottomLeft,
			bottomRight: bottomRight
		)
		
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.stroke(style, lineWidth: weight)
			)
			.apply(when: define) { rounded in
				rounded
					.contentShape(shape)
			}
	}
	
	#if canImport(UIKit)
	/// Using custom made ``RoundedCornersRectangle`` shape
	@inlinable
	func round(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners,
		tap define: Bool = false
	) -> some View {
		let shape = RoundedCornersRectangle(radius, corners)
		
		return self
			.clipShape(shape)
			.apply(when: define) { rounded in
				rounded.contentShape(shape)
			}
	}
	#endif
	
	/// Using custom made ``RoundedCornersRectangle`` shape
	@inlinable
	func round(
		topLeft: CGFloat,
		topRight: CGFloat,
		bottomLeft: CGFloat,
		bottomRight: CGFloat,
		tap define: Bool = false
	) -> some View {
		let shape = RoundedCornersRectangle(
			topLeft: topLeft,
			topRight: topRight,
			bottomLeft: bottomLeft,
			bottomRight: bottomRight
		)
		
		return self
			.clipShape(shape)
			.apply(when: define) { rounded in
				rounded
					.contentShape(shape)
			}
	}
}

// MARK: Line Position

/// Represents where a stroked border line should be placed relative to the
/// shape’s actual boundary when drawing borders (strokes).
///
/// Use this enum to control whether the stroke is centered on the boundary,
/// drawn entirely inside, or drawn entirely outside. This is especially useful
/// when you need pixel-perfect alignment or want to avoid clipping caused by
/// stroke thickness.
/// ## Cases
/// - ``center``\
///   The border line is centered on the shape’s boundary (default).
///   Half of the stroke lies inside and half outside.
/// - ``inner``\
///   The border line is inset so it lies fully inside the shape’s
///   boundary. Useful to prevent the stroke from being clipped by parent
///   views or to ensure the shape’s outer size remains unchanged.
/// - ``outer``\
///   The border line is outset so it lies fully outside the shape’s
///   boundary. Useful to preserve the interior content area exactly as sized.
/// ## Conformance
/// - `Hashable`
/// - `Sendable`
/// - `CaseIterable`
/// ## Utilities
/// - ``inset(for:)``\
///   Computes the inset amount for a given stroke weight:
///   - ``center`` returns
///     ```swift
///     0
///     ```
///   - ``inner`` returns
///     ```swift
///     weight / 2
///     ```
///   - ``outer`` returns
///     ```swift
///     -weight / 2
///     ```
/// ## Typical usage
/// - When overlaying a shape with `.stroke`/`.strokeBorder`, pass
///   `position.inset(for: weight)` to `.inset(by:)` so the stroke aligns
///   as desired without changing the view’s visual layout unexpectedly.
@IsCase
public enum LinePosition: Hashable, Sendable, CaseIterable, DefaultCaseFirst {
	case center
	case inner
	case outer
	
	/// Calculate the border line inset
	/// - Parameter weight: Border weight line to be insetted
	/// - Returns: Computes the inset amount for a given stroke `weight` and returns:
	///   - ``center``
	///     ```swift
	///     0
	///     ```
	///   - ``inner``
	///     ```swift
	///     weight / 2
	///     ```
	///   - ``outer``
	///     ```swift
	///     -weight / 2
	///     ```
	public func inset(for weight: CGFloat) -> CGFloat {
		switch self {
		case .center: .zero
		case .inner:   weight.half
		case .outer:  -weight.half
		}
	}
}

// MARK: Circle

extension View {
	@_disfavoredOverload
	@inlinable public func circle(
		border color: Color,
		weight: CGFloat = .one,
		position: LinePosition = .center
	) -> some View {
		let shape = Circle()
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.stroke(color, lineWidth: weight)
			)
	}
	
	@inlinable public func circle(
		border style: some ShapeStyle,
		weight: CGFloat = .one,
		position: LinePosition = .center
	) -> some View {
		let shape = Circle()
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.stroke(style, lineWidth: weight)
			)
	}
	
	@inlinable public func circle(
		weight: CGFloat = .one,
		position: LinePosition = .center
	) -> some View {
		let shape = Circle()
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.stroke(lineWidth: weight)
			)
	}
	
	@inlinable public func circleBorder(
		_ content: some ShapeStyle,
		lineWidth: CGFloat = 1,
		tap define: Bool = false
	) -> some View {
		let shape = Circle()
		return self
			.clipShape(shape)
			.overlay(shape.strokeBorder(content, lineWidth: lineWidth))
			.apply(when: define) { v in v
				.contentShape(shape)
			}
	}
	
	@inlinable public func circleBorder(
		_ color: Color,
		size: CGFloat = 1,
		tap define: Bool = false
	) -> some View {
		let shape = Circle()
		return self
			.clipShape(shape)
			.overlay(shape.strokeBorder(color, lineWidth: size))
			.apply(when: define) { v in v
				.contentShape(shape)
			}
	}
}

// MARK: Round Corners

extension View {
	/// Using system `RoundedRectangle` shape
	@inlinable public func corner(
		radius: CGFloat,
		tap define: Bool = false
	) -> some View {
		let shape = RoundedRectangle(radius)
		return self
			.clipShape(shape)
			.apply(when: define) { v in v
				.contentShape(shape)
			}
	}
	
	/// Using system `RoundedRectangle` shape
	@_disfavoredOverload
	@inlinable public func roundedBorder(
		_ color: Color,
		radius: CGFloat,
		weight: CGFloat = 1,
		position: LinePosition = .center,
		tap define: Bool = false
	) -> some View {
		let shape = RoundedRectangle(radius)
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.strokeBorder(color, lineWidth: weight)
			)
			.apply(when: define) { v in v
				.contentShape(shape)
			}
	}
	
	/// Using system `RoundedRectangle` shape
	@inlinable public func roundedBorder(
		_ style: some ShapeStyle,
		radius: CGFloat,
		weight: CGFloat = 1,
		position: LinePosition = .center,
		tap define: Bool = false
	) -> some View {
		let shape = RoundedRectangle(radius)
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.strokeBorder(style, lineWidth: weight)
			)
			.apply(when: define) { v in v
				.contentShape(shape)
			}
	}
	
	/// Using system `RoundedRectangle` shape
	@ViewBuilder
	public func roundedBorder(
		_ style: some ShapeStyle,
		radius: CGFloat,
		weight: CGFloat = 1,
		position: LinePosition = .center,
		contentShapeKind: ContentShapeKinds
	) -> some View {
		let shape = RoundedRectangle(radius)
		
		self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.strokeBorder(style, lineWidth: weight)
			)
			.contentShape(contentShapeKind, shape)
	}
	
	#if canImport(UIKit)
	/// Using custom made ``RoundedCornersRectangle`` shape
	@_disfavoredOverload
	@inlinable public func roundButton(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners,
		border color: Color,
		weight: CGFloat = .one,
		position: LinePosition = .center
	) -> some View {
		let shape = RoundedCornersRectangle(radius, corners)
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.stroke(color, lineWidth: weight)
			)
			.contentShape(shape)
	}
	
	/// Using custom made ``RoundedCornersRectangle`` shape
	@inlinable public func roundButton(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners,
		border style: some ShapeStyle,
		weight: CGFloat = .one,
		position: LinePosition = .center
	) -> some View {
		let shape = RoundedCornersRectangle(radius, corners)
		return self
			.clipShape(shape)
			.overlay(
				shape
					.inset(by: position.inset(for: weight))
					.stroke(style, lineWidth: weight)
			)
			.contentShape(shape)
	}
	
	/// Using custom made ``RoundedCornersRectangle`` shape
	@inlinable public func roundButton(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners
	) -> some View {
		let shape = RoundedCornersRectangle(radius, corners)
		return self
			.clipShape(shape)
			.contentShape(shape)
	}
	#endif
}

extension RoundedRectangle {
	/// Simplified init with `.continuous` style
	@inlinable public init(_ radius: CGFloat) {
		self.init(cornerRadius: radius, style: .continuous)
	}
}

// MARK: - Previews

#if DEBUG
@available(iOS 17, *)
#Preview("roundedBorder", traits: .sizeThatFitsLayout) {
	VStack {
		Color.blue
			.frame(width: 100, height: 100)
			.roundedBorder(Color.pink, radius: 10, weight: 4)
		
		Color.white
			.frame(width: 100, height: 100)
			.roundedBorder(Color.black, radius: 10, weight: 1/3)
	}
	.clipped()
	.padding()
}
#endif
