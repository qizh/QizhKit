//
//  Shape+sugar.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

public import SwiftUI

// MARK: - Clip

extension View {
	@inlinable public func clipCircle() -> some View {
		clipShape(Circle())
	}
}

// MARK: - Fill & Stroke

extension Shape {
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		lineWidth: CGFloat = .one
	) -> some View {
		self
			.stroke(strokeColor, lineWidth: lineWidth)
			.background(self.fill(fillStyle))
	}
	
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		style strokeStyle: StrokeStyle
	) -> some View {
		self
			.stroke(strokeColor, style: strokeStyle)
			.background(self.fill(fillStyle))
	}
}

extension InsettableShape {
	/// Fills the shape with the specified style and draws a stroked border using a line
	/// width.
	///
	/// This convenience modifier first renders the shape’s interior using the provided
	/// `fillStyle`, then overlays a stroke along the shape’s path using `strokeColor`
	/// and `lineWidth`. The fill is placed behind the stroke to ensure a crisp outline
	/// without obscuring the fill.
	/// - Parameters:
	///   - fillStyle: The style used to fill the interior of the shape. You can pass any
	///     `ShapeStyle`, such as `Color`, `Gradient`, `.tint`, or `.foregroundStyle`.
	///   - strokeColor: The style used to draw the border of the shape. Accepts any
	///     `ShapeStyle`, allowing solid colors, materials, or gradients.
	///   - lineWidth: The thickness of the border line, in points. Defaults to `1.0`.
	/// - Returns: A view that first fills the shape with `fillStyle` and then draws a
	///   stroked outline using `strokeColor` and `lineWidth`.
	/// This variant uses `stroke(_:lineWidth:)`, which centers the stroke on the
	/// shape’s path. If you need the stroke to be drawn strictly inside or outside
	/// the shape’s bounds, consider using an `InsettableShape` and its
	/// `strokeBorder`-based variant instead.
	/// - SeeAlso:
	///   - `Shape.stroke(_:lineWidth:)`
	///   - `Shape.fill(_:style:)`
	///   - `InsettableShape.fill(_:strokeBorder:lineWidth:)`
	///   - `InsettableShape.strokeBorder(_:lineWidth:)`
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		lineWidth: CGFloat = .one
	) -> some View {
		self
			.strokeBorder(strokeColor, lineWidth: lineWidth)
			.background(self.fill(fillStyle))
	}
	
	/// Fills the shape with the specified style and draws a stroked border using a custom
	/// stroke style.
	///
	/// This modifier first renders the shape’s interior using `fillStyle`, then overlays
	/// a stroked outline using `strokeColor` and the provided `strokeStyle`.
	/// It is a convenience that mirrors SwiftUI’s `fill(_:style:)` + `stroke(_:style:)`,
	/// ensuring the fill remains visually beneath the stroke.
	/// - Parameters:
	///   - fillStyle: The style used to fill the interior of the shape. You can pass any
	///     `ShapeStyle`, such as `Color`, `Gradient`, `.tint`, or `.foregroundStyle`.
	///   - strokeColor: The style used to draw the border of the shape. Accepts any
	///     `ShapeStyle`, allowing solid colors, materials, or gradients.
	///   - strokeStyle: A `StrokeStyle` that configures how the border is drawn, including
	///     line width, line cap, line join, miter limit, dash pattern, and dash phase.
	/// - Returns: A view that first fills the shape with `fillStyle` and then draws a
	///   stroked outline using `strokeColor` and `strokeStyle`.
	/// Use this when you want a filled shape with a customized outline in a single call.
	/// The stroke is drawn over the fill, maintaining a clear border while preserving
	/// the fill’s appearance. If you need the stroke to be inset relative to the shape’s
	/// path, consider using an `InsettableShape` and its `strokeBorder`-based variants.
	/// - SeeAlso:
	///   - `Shape.fill(_:strokeBorder:lineWidth:)`
	///   - `Shape.stroke(_:lineWidth:)`
	///   - `Shape.stroke(_:style:)`
	///   - `InsettableShape.strokeBorder(_:lineWidth:)`
	///   - `InsettableShape.stroke(border:thickness:with:opacity:smooth:)`
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		style strokeStyle: StrokeStyle
	) -> some View {
		self
			.strokeBorder(strokeColor, style: strokeStyle)
			.background(self.fill(fillStyle))
	}
	
	/// Strokes the outline of the shape with configurable border positioning, thickness,
	/// style, and antialiasing.
	///
	/// This method draws the stroke along the shape’s path by first insetting the shape
	/// according to the desired border position (inside, center, or outside) for the
	/// given thickness, then applying a `strokeBorder` with the specified style. It is
	/// especially useful when you want precise control over whether the stroke appears
	/// inside, centered on, or outside the original shape boundary.
	/// - Parameters:
	///   - position: The relative placement of the stroke in relation to the shape’s path.
	///     Use `.inside`, `.center`, or `.outside`. The default is `.default`,
	///     which is `.center`.
	///   - thickness: The width of the stroke in points. The default is `1.0`.
	///   - style: The `ShapeStyle` used to render the stroke
	///     (for example, `.tint`, `Color`, `LinearGradient`).
	///   - opacity: A value between `0.0` (fully transparent) and `1.0` (fully opaque)
	///     applied to the stroke style. The default is `1.0`.
	///   - antialiased: A `Boolean` value that indicates whether SwiftUI should smooth
	///     edges when drawing the stroke. The default is `true`.
	/// - Returns:
	///   A view that draws the shape’s stroke according to the provided parameters.
	/// - Requires:
	///   This modifier is available on types conforming to `InsettableShape`, enabling
	///   accurate border placement by insetting the shape before stroking. The inset
	///   amount is computed from the `position` and `thickness`, preventing visual growth
	///   or shrinkage of the shape when placing the stroke strictly inside or outside.
	/// - SeeAlso:
	///   - `strokeBorder(_:lineWidth:antialiased:)`
	///   - `InsettableShape`
	///   - ``LinePosition``
	public func stroke(
		border position: LinePosition = .default,
		thickness: CGFloat = 1.0,
		with style: some ShapeStyle,
		opacity: Double = 1.0,
		smooth antialiased: Bool = true
	) -> some View {
		self.inset(by: position.inset(for: thickness))
			.strokeBorder(style.opacity(opacity), lineWidth: thickness, antialiased: antialiased)
			
	}
}

// MARK: - Any Shape

extension Shape {
	public var asAnyShape: AnyShape {
		AnyShape(self)
	}
}

// MARK: - Animatable

/// A type alias for animating three values of type `T` that conforms to `VectorArithmetic`.
///
/// Structured as `AnimatablePair<AnimatablePair<T, T>, T>`, allowing SwiftUI
/// to interpolate three related values (for example, RGB components or x/y/z coordinates).
public typealias AnimatableTrio<T> = AnimatablePair<AnimatablePair<T, T>, T> where T: VectorArithmetic

/// A type alias for animating four values of type `T` that conforms to `VectorArithmetic`.
///
/// Structured as `AnimatablePair<AnimatablePair<T, T>, AnimatablePair<T, T>>`,
/// suitable for RGBA colors, quaternion-like structures, or any four-component data.
public typealias AnimatableQuartet<T> = AnimatablePair<AnimatablePair<T, T>, AnimatablePair<T, T>> where T: VectorArithmetic

/// A type alias for animating two `CGFloat` values.
///
/// Commonly used for 2D positions, sizes, or offsets in SwiftUI animations.
public typealias AnimatableCGFloatPair = AnimatablePair<CGFloat, CGFloat>

/// A type alias for animating four `CGFloat` values.
///
/// Useful for animating rectangles (origin + size), edge insets, or other
/// four-component geometric data in SwiftUI.
public typealias AnimatableCGFloatQuartet = AnimatableQuartet<CGFloat>

