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
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		lineWidth: CGFloat = .one
	) -> some View {
		self
			.strokeBorder(strokeColor, lineWidth: lineWidth)
			.background(self.fill(fillStyle))
	}
	
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		style strokeStyle: StrokeStyle
	) -> some View {
		self
			.strokeBorder(strokeColor, style: strokeStyle)
			.background(self.fill(fillStyle))
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
